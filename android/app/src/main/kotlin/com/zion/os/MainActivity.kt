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
    private val ioExecutor = Executors.newSingleThreadExecutor()\n\n    companion object {\n        init { System.loadLibrary("zionpty") }\n    }
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
                    "resize" -> resizeShell(call, result)
                    "stop" -> stopShell(result)
                    else -> result.notImplemented()
                }
            }
    }

    private external fun nativeStartPty(command: String, cwd: String, argv: Array<String>, env: Array<String>, rows: Int, cols: Int): Int
    private external fun nativeReadPty(): ByteArray?
    private external fun nativeWritePty(data: ByteArray): Int
    private external fun nativeResizePty(rows: Int, cols: Int): Boolean
    private external fun nativeStopPty()

    private fun startShell(result: MethodChannel.Result) {
        try {
            val root = File(filesDir, "termux")
            val prefix = File(root, "usr")
            val home = File(root, "home")
            val tmp = File(root, "tmp")
            home.mkdirs(); prefix.mkdirs(); tmp.mkdirs()
            installBootstrapIfPresent(root)
            val bash = File(prefix, "bin/bash")
            val executable = if (bash.canExecute()) bash.absolutePath else "/system/bin/sh"
            val env = arrayOf(
                "HOME=${home.absolutePath}",
                "PREFIX=${prefix.absolutePath}",
                "TERMUX_PREFIX=${prefix.absolutePath}",
                "TMPDIR=${tmp.absolutePath}",
                "PATH=${File(prefix, "bin").absolutePath}:/system/bin:/system/xbin",
                "TERM=xterm-256color",
                "LANG=C.UTF-8",
                "PS1=zion@os:\\w\\$ "
            )
            val argv = arrayOf(executable, "-i")
            val fd = nativeStartPty(executable, home.absolutePath, argv, env, 30, 100)
            if (fd < 0) { result.success(false); return }
            ioExecutor.execute {
                while (true) {
                    val bytes = nativeReadPty() ?: break
                    outputSink?.success(String(bytes, Charsets.UTF_8))
                }
            }
            result.success(true)
        } catch (error: Exception) {
            outputSink?.error("START_FAILED", error.message, null)
            result.success(false)
        }
    }

    private fun writeShell(input: String, result: MethodChannel.Result) {
        try {
            if (nativeWritePty(input.toByteArray(Charsets.UTF_8)) < 0) {
                result.error("WRITE_FAILED", "PTY is not running.", null)
            } else result.success(null)
        } catch (error: Exception) {
            result.error("WRITE_FAILED", error.message, null)
        }
    }

    private fun resizeShell(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        result.success(nativeResizePty(call.argument<Int>("rows") ?: 30, call.argument<Int>("cols") ?: 100))
    }

    private fun stopShell(result: MethodChannel.Result) {
        nativeStopPty()
        result.success(null)
    }

    private fun installBootstrapIfPresent(root: File) {
        val marker = File(root, ".bootstrap-installed")
        if (marker.exists()) return
        assets.list("termux")?.filter { it.endsWith(".zip") }?.forEach { name ->
            val zipFile = File(cacheDir, name)
            assets.open("termux/${name}").use { input -> zipFile.outputStream().use { input.copyTo(it) } }
            java.util.zip.ZipInputStream(zipFile.inputStream().buffered()).use { zip ->
                var entry = zip.nextEntry
                while (entry != null) {
                    val destination = File(root, entry.name)
                    if (entry.isDirectory) destination.mkdirs()
                    else {
                        destination.parentFile?.mkdirs()
                        destination.outputStream().use { zip.copyTo(it) }
                        if (destination.name != "bash") destination.setExecutable(true, false)
                    }
                    entry = zip.nextEntry
                }
            }
            zipFile.delete()
            marker.writeText("installed")
        }
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