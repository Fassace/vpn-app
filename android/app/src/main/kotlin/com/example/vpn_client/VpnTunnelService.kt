package com.example.vpn_client.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.example.vpn_client.MainActivity
import com.wireguard.android.backend.GoBackend
import com.wireguard.config.Config
import java.lang.Exception

class VpnTunnelService : VpnService() {
    companion object {
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
        private const val CHANNEL_ID = "vpn_channel"
        private const val NOTIF_ID = 1001
        @Volatile private var currentStatus: String = "disconnected"
        fun statusString() = currentStatus
    }

    private var backend: GoBackend? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                // read params from extras
                val serverAddress = intent.getStringExtra("serverAddress") ?: ""
                val serverPort = intent.getIntExtra("serverPort", -1)
                val privateKey = intent.getStringExtra("privateKey") ?: ""
                val peerPublicKey = intent.getStringExtra("peerPublicKey") ?: ""
                val peerAllowedIps = intent.getStringExtra("peerAllowedIps") ?: "0.0.0.0/0"

                startVpn(serverAddress, serverPort, privateKey, peerPublicKey, peerAllowedIps)
            }
            ACTION_STOP -> stopVpn()
        }
        return START_STICKY
    }

    private fun startVpn(serverAddress: String, serverPort: Int, privateKey: String, peerPublicKey: String, allowedIps: String) {
        currentStatus = "connecting"
        startForeground(NOTIF_ID, buildNotification("Connecting…"))

        try {
            // Build a WireGuard config string. Keep this minimal and safe.
            val configText = """
                [Interface]
                PrivateKey = $privateKey
                Address = 10.0.0.2/32
                DNS = 1.1.1.1

                [Peer]
                PublicKey = $peerPublicKey
                AllowedIPs = $allowedIps
                Endpoint = $serverAddress:$serverPort
            """.trimIndent()

            val config = Config.parse(configText)

            // initialize GoBackend and set the tunnel state to UP
            backend = GoBackend(this)
            // "wg0" is the tunnel name. The tunnel state enum is inside Tunnel.State (UP/DOWN)
            backend!!.setState("wg0", config, com.wireguard.android.backend.Tunnel.State.UP)

            currentStatus = "connected"
        } catch (e: Exception) {
            e.printStackTrace()
            currentStatus = "error"
        }

        updateNotification(currentStatus)
    }

    private fun stopVpn() {
        currentStatus = "disconnecting"
        try {
            backend?.setState("wg0", null, com.wireguard.android.backend.Tunnel.State.DOWN)
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            backend = null
            currentStatus = "disconnected"
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
        }
    }

    private fun buildNotification(content: String): Notification {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(CHANNEL_ID, "VPN", NotificationManager.IMPORTANCE_LOW)
            nm.createNotificationChannel(channel)
        }
        val pi = PendingIntent.getActivity(this, 0, Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE)
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("VPN Client")
            .setContentText(content)
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setContentIntent(pi)
            .build()
    }

    private fun updateNotification(text: String) {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIF_ID, buildNotification(text))
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
