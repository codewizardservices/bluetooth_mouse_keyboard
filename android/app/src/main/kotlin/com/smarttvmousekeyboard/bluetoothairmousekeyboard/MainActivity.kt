package com.smarttvmousekeyboard.bluetoothairmousekeyboard

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the plugin manually
        val plugin = BluetoothHidPlugin()
        val channel = io.flutter.plugin.common.MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.smarttvmousekeyboard.bluetoothairmousekeyboard/bluetooth_hid"
        )
        channel.setMethodCallHandler(plugin)
        
        // Initialize plugin context
        val context = applicationContext
        val bluetoothManager = context.getSystemService(android.content.Context.BLUETOOTH_SERVICE) as android.bluetooth.BluetoothManager
        plugin.initialize(context, bluetoothManager.adapter)
    }
}
