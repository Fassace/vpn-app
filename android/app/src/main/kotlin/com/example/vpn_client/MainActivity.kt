package com.example.vpn_client

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.vpn_client.vpn.VpnTunnelService

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.vpn/channel"
    private val REQUEST_VPN_PERMISSION = 1001

    // store pending args if consent flow needed
    private var pendingStartArgs: Map<String, Any>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val args = call.arguments as? Map<String, Any> ?: emptyMap()
                    startVpnWithConsent(args)
                    result.success(null)
                }
                "stop" -> {
                    val i = Intent(this, VpnTunnelService::class.java).apply { action = VpnTunnelService.ACTION_STOP }
                    startService(i)
                    result.success(null)
                }
                "status" -> {
                    result.success(VpnTunnelService.statusString())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startVpnWithConsent(args: Map<String, Any>) {
        // Check if user already granted VPN permission
        val intent = VpnService.prepare(this)
        if (intent != null) {
            // Need user consent — store args and start consent activity
            pendingStartArgs = args
            startActivityForResult(intent, REQUEST_VPN_PERMISSION)
        } else {
            // Already have permission; start service immediately
            startVpnService(args)
        }
    }

    private fun startVpnService(args: Map<String, Any>) {
        val i = Intent(this, VpnTunnelService::class.java).apply {
            action = VpnTunnelService.ACTION_START
            // pass config params as extras — safe copying
            putExtra("serverAddress", args["serverAddress"] as? String)
            putExtra("serverPort", (args["serverPort"] as? Int) ?: -1)
            putExtra("privateKey", args["privateKey"] as? String)
            putExtra("peerPublicKey", args["publicKey"] as? String)
            putExtra("peerAllowedIps", args["allowedIps"] as? String) // e.g. "0.0.0.0/0"
        }
        startForegroundService(i)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_VPN_PERMISSION) {
            if (resultCode == Activity.RESULT_OK) {
                // user granted consent
                pendingStartArgs?.let { startVpnService(it) }
                pendingStartArgs = null
            } else {
                // user denied — you may send a callback via MethodChannel if needed
                pendingStartArgs = null
            }
        }
    }
}
