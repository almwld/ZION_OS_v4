package com.zion.os

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val systemChannel = "zion/system"
    private val terminalChannel = "zion.os/pty"
    private val terminalEvents = "zion.os/pty/events"
    private val ioExecutor = Executors.newSingleThreadExecutor()
    @Volatile private var shellProcess: Process? = null
    @Volatile private var outputSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, systemChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scanWifi" -> scanWifi(result)
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, terminalEvents)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    outputSink = events
                }
                override fun onCancel(arguments: Any?) {
                    outputSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, terminalChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "available" -> result.success(true)
                    "start" -> startShell(result)
                    "write" -> writeShell(call.argument<String>("input").orEmpty(), result)
                    "resize" -> result.success(true)
                    "stop" -> stopShell(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun startShell(result: MethodChannel.Result) {
        if (shellProcess?.isAlive == true) {
            result.success(true)
            return
        }

        try {
            val root = File(filesDir, "termux")
            val prefix = File(root, "usr")
            val home = File(root, "home")
            val tmp = File(root, "tmp")
            home.mkdirs()
            prefix.mkdirs()
            tmp.mkdirs()

            val bash = File(prefix, "bin/bash")
            val executable = if (bash.canExecute()) bash.absolutePath else "/system/bin/sh"
            val process = ProcessBuilder(executable, "-i")
                .directory(home)
                .redirectErrorStream(true)
                .apply {
                    environment()["HOME"] = home.absolutePath
                    environment()["PREFIX"] = prefix.absolutePath
                    environment()["TERMUX_PREFIX"] = prefix.absolutePath
                    environment()["TMPDIR"] = tmp.absolutePath
                    environment()["PATH"] = File(prefix, "bin").absolutePath + ":/system/bin:/system/xbin"
                    environment()["TERM"] = "xterm-256color"
                    environment()["LANG"] = "C.UTF-8"
                    environment()["PS1"] = "zion@os:\\w\\$ "
                }
                .start()

            shellProcess = process
            ioExecutor.execute {
                BufferedReader(InputStreamReader(process.inputStream)).useLines { lines ->
                    lines.forEach { line -> outputSink?.success(line + "\\n") }
                }
                val code = process.waitFor()
                outputSink?.success("\\n[ZION] shell exited (code " + code + ")\\n")
                shellProcess = null
            }
            result.success(true)
        } catch (error: Exception) {
            outputSink?.error("START_FAILED", error.message, null)
            result.success(false)
        }
    }

    private fun writeShell(input: String, result: MethodChannel.Result) {
        val process = shellProcess
        if (process == null || !process.isAlive) {
            result.error("NOT_RUNNING", "Shell process is not running.", null)
            return
        }
        try {
            process.outputStream.write(input.toByteArray(Charsets.UTF_8))
            process.outputStream.flush()
            result.success(null)
        } catch (error: Exception) {
            result.error("WRITE_FAILED", error.message, null)
        }
    }

    private fun stopShell(result: MethodChannel.Result) {
        shellProcess?.destroy()
        shellProcess = null
        result.success(null)
    }

    override fun onDestroy() {
        shellProcess?.destroy()
        shellProcess = null
        ioExecutor.shutdownNow()
        super.onDestroy()
    }

    private fun scanWifi(result: MethodChannel.Result) {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        if (wifiManager == null) { result.error("UNAVAILABLE", "Wi-Fi service is unavailable", null); return }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.NEARBY_WIFI_DEVICES) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Nearby Wi-Fi permission is required", null); return
        }
        if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Location permission is required for Wi-Fi scanning", null); return
        }
        if (!wifiManager.isWifiEnabled) { result.error("WIFI_DISABLED", "Wi-Fi is disabled", null); return }

        val filter = IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: android.content.Intent?) {
                try {
                    result.success(wifiManager.scanResults.map { scan ->
                        mapOf("ssid" to scan.SSID, "bssid" to scan.BSSID, "signal" to scan.level,
                            "frequency" to scan.frequency, "capabilities" to scan.capabilities, "timestamp" to scan.timestamp)
                    })
                } catch (error: SecurityException) {
                    result.error("PERMISSION_DENIED", error.message, null)
                } finally {
                    try { unregisterReceiver(this) } catch (_: IllegalArgumentException) {}
                }
            }
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                @Suppress("DEPRECATION") registerReceiver(receiver, filter)
            }
            @Suppress("DEPRECATION") val started = wifiManager.startScan()
            if (!started) {
                try { unregisterReceiver(receiver) } catch (_: IllegalArgumentException) {}
                result.error("SCAN_REJECTED", "Android rejected the Wi-Fi scan request", null)
            }
        } catch (error: SecurityException) {
            try { unregisterReceiver(receiver) } catch (_: IllegalArgumentException) {}
            result.error("PERMISSION_DENIED", error.message, null)
        }
    }
}