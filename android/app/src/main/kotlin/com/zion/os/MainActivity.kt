package com.zion.os

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "zion/system"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scanWifi" -> scanWifi(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun scanWifi(result: MethodChannel.Result) {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        if (wifiManager == null) {
            result.error("UNAVAILABLE", "Wi-Fi service is unavailable", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.NEARBY_WIFI_DEVICES) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Nearby Wi-Fi permission is required", null)
            return
        }

        if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Location permission is required for Wi-Fi scanning on this Android version", null)
            return
        }

        if (!wifiManager.isWifiEnabled) {
            result.error("WIFI_DISABLED", "Wi-Fi is disabled", null)
            return
        }

        val filter = IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                try {
                    val results = wifiManager.scanResults.map { scan ->
                        mapOf(
                            "ssid" to (scan.SSID ?: ""),
                            "bssid" to scan.BSSID,
                            "signal" to scan.level,
                            "frequency" to scan.frequency,
                            "capabilities" to scan.capabilities,
                            "timestamp" to scan.timestamp,
                        )
                    }
                    result.success(results)
                } catch (e: SecurityException) {
                    result.error("PERMISSION_DENIED", e.message, null)
                } finally {
                    try {
                        unregisterReceiver(this)
                    } catch (_: IllegalArgumentException) {
                    }
                }
            }
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                @Suppress("DEPRECATION")
                registerReceiver(receiver, filter)
            }

            @Suppress("DEPRECATION")
            val started = wifiManager.startScan()
            if (!started) {
                try {
                    unregisterReceiver(receiver)
                } catch (_: IllegalArgumentException) {
                }
                result.error("SCAN_REJECTED", "Android rejected the Wi-Fi scan request", null)
            }
        } catch (e: SecurityException) {
            try {
                unregisterReceiver(receiver)
            } catch (_: IllegalArgumentException) {
            }
            result.error("PERMISSION_DENIED", e.message, null)
        }
    }
}
