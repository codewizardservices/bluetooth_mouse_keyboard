package com.smarttvmousekeyboard.bluetoothairmousekeyboard

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothHidDevice
import android.bluetooth.BluetoothHidDeviceAppSdpSettings
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class BluetoothHidPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var bluetoothAdapter: BluetoothAdapter? = null

    fun initialize(context: Context, adapter: BluetoothAdapter?) {
        this.context = context
        this.bluetoothAdapter = adapter
    }

    private var bluetoothHidDevice: BluetoothHidDevice? = null
    private var bluetoothDevice: BluetoothDevice? = null

    private var _isServiceRunning = false
    private var _isProfileRegistered = false

    // Keep as your existing "getConnectionState" returns a map
    private var _connectionState: Map<String, Any?> = mapOf(
        "state" to 0,
        "deviceName" to "",
        "deviceAddress" to ""
    )

    companion object {
        private const val CHANNEL_NAME = "com.smarttvmousekeyboard.bluetoothairmousekeyboard/bluetooth_hid"

        // HID Descriptor
        private val HID_DESCRIPTOR = byteArrayOf(
            // Remote Control
            0x05.toByte(), 0x0C.toByte(),                    // Usage Page (Consumer Devices)
            0x09.toByte(), 0x01.toByte(),                    // Usage (Consumer Control)
            0xA1.toByte(), 0x01.toByte(),                    // Collection (Application)
            0x85.toByte(), 0x02.toByte(),                    //   Report ID (2)
            0x19.toByte(), 0x00.toByte(),                    //   Usage Minimum (Unassigned)
            0x2A.toByte(), 0xFF.toByte(), 0x03.toByte(),     //   Usage Maximum (1023)
            0x75.toByte(), 0x10.toByte(),                    //   Report Size (16)
            0x95.toByte(), 0x01.toByte(),                    //   Report Count (1)
            0x15.toByte(), 0x00.toByte(),                    //   Logical Minimum (0)
            0x26.toByte(), 0xFF.toByte(), 0x03.toByte(),     //   Logical Maximum (1023)
            0x81.toByte(), 0x00.toByte(),                    //   Input (Data,Array,Absolute)
            0xC0.toByte(),                                   // End Collection

            // Keyboard
            0x05.toByte(), 0x01.toByte(),                    // Usage Page (Generic Desktop)
            0x09.toByte(), 0x06.toByte(),                    // Usage (Keyboard)
            0xA1.toByte(), 0x01.toByte(),                    // Collection (Application)
            0x85.toByte(), 0x01.toByte(),                    //   Report ID (1)
            0x05.toByte(), 0x07.toByte(),                    //   Usage Page (Keyboard Key Codes)
            0x19.toByte(), 0xE0.toByte(),                    //   Usage Minimum (224)
            0x29.toByte(), 0xE7.toByte(),                    //   Usage Maximum (231)
            0x15.toByte(), 0x00.toByte(),                    //   Logical Minimum (0)
            0x25.toByte(), 0x01.toByte(),                    //   Logical Maximum (1)
            0x75.toByte(), 0x01.toByte(),                    //   Report Size (1)
            0x95.toByte(), 0x08.toByte(),                    //   Report Count (8)
            0x81.toByte(), 0x02.toByte(),                    //   Input (Data,Variable,Absolute)
            0x75.toByte(), 0x08.toByte(),                    //    Report Size (8)
            0x95.toByte(), 0x01.toByte(),                    //    Report Count (1)
            0x15.toByte(), 0x00.toByte(),                    //    Logical Minimum (0)
            0x26.toByte(), 0xFF.toByte(), 0x00.toByte(),     //    Logical Maximum (255)
            0x05.toByte(), 0x07.toByte(),                    //    Usage Page (Keyboard Key Codes)
            0x19.toByte(), 0x00.toByte(),                    //    Usage Minimum (0)
            0x29.toByte(), 0xFF.toByte(),                    //    Usage Maximum (255)
            0x81.toByte(), 0x00.toByte(),                    //    Input (Data,Array,Absolute)
            0xC0.toByte(),                                   // End Collection

            // Mouse
            0x05.toByte(), 0x01.toByte(),                    // Usage Page (Generic Desktop)
            0x09.toByte(), 0x02.toByte(),                    // Usage (Mouse)
            0xA1.toByte(), 0x01.toByte(),                    // Collection (Application)
            0x85.toByte(), 0x03.toByte(),                    //   Report ID (3)
            0x09.toByte(), 0x01.toByte(),                    //   Usage (Pointer)
            0xA1.toByte(), 0x00.toByte(),                    //   Collection (Physical)
            0x05.toByte(), 0x09.toByte(),                    //     Usage Page (Button)
            0x19.toByte(), 0x01.toByte(),                    //     Usage Minimum (1)
            0x29.toByte(), 0x03.toByte(),                    //     Usage Maximum (3)
            0x15.toByte(), 0x00.toByte(),                    //     Logical Minimum (0)
            0x25.toByte(), 0x01.toByte(),                    //     Logical Maximum (1)
            0x75.toByte(), 0x01.toByte(),                    //     Report Size (1)
            0x95.toByte(), 0x03.toByte(),                    //     Report Count (3)
            0x81.toByte(), 0x02.toByte(),                    //     Input (Data,Variable,Absolute)
            0x75.toByte(), 0x05.toByte(),                    //     Report Size (5)
            0x95.toByte(), 0x01.toByte(),                    //     Report Count (1)
            0x81.toByte(), 0x01.toByte(),                    //     Input (Constant,Array,Absolute)
            0x05.toByte(), 0x01.toByte(),                    //     Usage Page (Generic Desktop)
            0x09.toByte(), 0x30.toByte(),                    //     Usage (X)
            0x09.toByte(), 0x31.toByte(),                    //     Usage (Y)
            0x09.toByte(), 0x38.toByte(),                    //     Usage (Wheel)
            0x15.toByte(), 0x81.toByte(),                    //     Logical Minimum (-127)
            0x25.toByte(), 0x7F.toByte(),                    //     Logical Maximum (127)
            0x75.toByte(), 0x08.toByte(),                    //     Report Size (8)
            0x95.toByte(), 0x03.toByte(),                    //     Report Count (3)
            0x81.toByte(), 0x06.toByte(),                    //     Input (Data,Variable,Relative)
            0xC0.toByte(),                                   //   End Collection
            0xC0.toByte()                                    // End Collection
        )
    }

    // ----------------------------
    // Helpers to return full message
    // ----------------------------

    private fun resp(
        ok: Boolean,
        message: String,
        code: String? = null,
        details: Map<String, Any?> = emptyMap()
    ): Map<String, Any?> {
        val m = mutableMapOf<String, Any?>(
            "ok" to ok,
            "message" to message
        )
        if (!code.isNullOrBlank()) m["code"] = code
        if (details.isNotEmpty()) m["details"] = details
        return m
    }

    private fun hasBluetoothConnectPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED
        } else true
    }

    private fun ensureBluetoothReady(): Map<String, Any?>? {
        val adapter = bluetoothAdapter
        if (adapter == null) return resp(false, "Bluetooth adapter not available", "NO_BLUETOOTH_ADAPTER")
        if (!adapter.isEnabled) return resp(false, "Bluetooth is turned off", "BLUETOOTH_DISABLED")
        if (!hasBluetoothConnectPermission()) return resp(false, "Missing BLUETOOTH_CONNECT permission", "MISSING_PERMISSION")
        return null
    }

    // ----------------------------
    // Flutter plugin lifecycle
    // ----------------------------

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext

        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager.adapter
    }

    fun setChannel(channel: MethodChannel) {
        this.channel = channel
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stopHidProfile() // return value ignored
    }

    // ----------------------------
    // MethodChannel handler
    // ----------------------------

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            "startHidProfile" -> {
                val deviceAddress = call.argument<String>("deviceAddress") ?: ""
                startHidProfile(deviceAddress, result) // async -> calls result.success(map)
            }

            "stopHidProfile" -> {
                result.success(stopHidProfile())
            }

            "connectDevice" -> {
                val deviceAddress = call.argument<String>("deviceAddress") ?: ""
                result.success(connectDevice(deviceAddress))
            }

            "disconnectDevice" -> {
                result.success(disconnectDevice())
            }

            "sendReport" -> {
                val reportId = call.argument<Int>("reportId") ?: 0
                val data = call.argument<ByteArray>("data") ?: byteArrayOf()
                result.success(sendReport(reportId, data))
            }

            "getConnectionState" -> {
                result.success(_connectionState)
            }

            "isServiceRunning" -> {
                result.success(_isServiceRunning)
            }

            "isProfileRegistered" -> {
                result.success(_isProfileRegistered)
            }

            "getPairedDevices" -> {
                try {
                    val devices = getPairedDevices()
                    result.success(
                        resp(
                            ok = true,
                            message = "Paired devices fetched",
                            code = "PAIRED_DEVICES_OK",
                            details = mapOf("count" to devices.size, "devices" to devices)
                        )
                    )
                } catch (e: Exception) {
                    result.success(
                        resp(
                            ok = false,
                            message = "Failed to get paired devices: ${e.message}",
                            code = "GET_PAIRED_FAILED",
                            details = mapOf("exception" to e.toString())
                        )
                    )
                }
            }

            else -> result.notImplemented()
        }
    }

    // ----------------------------
    // Existing method (kept)
    // ----------------------------

    private fun getPairedDevices(): List<Map<String, String>> {
        val list = mutableListOf<Map<String, String>>()
        val adapter = bluetoothAdapter

        Log.i("BluetoothHidPlugin", "adapter null: ${adapter == null}")
        Log.i("BluetoothHidPlugin", "enabled: ${adapter?.isEnabled}")

        if (adapter == null || !adapter.isEnabled) return list

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val granted = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED

            Log.i("BluetoothHidPlugin", "BLUETOOTH_CONNECT granted: $granted")
            if (!granted) return list
        }

        val bonded = adapter.bondedDevices
        Log.i("BluetoothHidPlugin", "bonded count: ${bonded.size}")

        bonded.forEach { device ->
            list.add(mapOf("name" to (device.name ?: "Unknown"), "address" to device.address))
        }
        return list
    }

    // ----------------------------
    // HID start/register
    // ----------------------------

    private fun startHidProfile(deviceAddress: String, result: MethodChannel.Result) {
        ensureBluetoothReady()?.let { result.success(it); return }

        val adapter = bluetoothAdapter!!
        val hidSettings = BluetoothHidDeviceAppSdpSettings(
            "BT Remote",
            "Bluetooth HID Device",
            "Atharok",
            BluetoothHidDevice.SUBCLASS2_UNCATEGORIZED,
            HID_DESCRIPTOR
        )

        adapter.getProfileProxy(
            context,
            object : BluetoothProfile.ServiceListener {

                override fun onServiceConnected(profile: Int, proxy: BluetoothProfile?) {
                    if (profile != BluetoothProfile.HID_DEVICE) {
                        result.success(resp(false, "Unexpected profile: $profile", "WRONG_PROFILE"))
                        return
                    }

                    bluetoothHidDevice = proxy as? BluetoothHidDevice
                    val hidDevice = bluetoothHidDevice
                    if (hidDevice == null) {
                        result.success(resp(false, "Failed to get BluetoothHidDevice proxy", "HID_PROXY_NULL"))
                        return
                    }

                    _isServiceRunning = true

                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                        _isProfileRegistered = false
                        result.success(
                            resp(
                                ok = false,
                                message = "Android < 12 (API 31) is not supported for registerApp in this implementation",
                                code = "UNSUPPORTED_ANDROID_VERSION",
                                details = mapOf("sdkInt" to Build.VERSION.SDK_INT)
                            )
                        )
                        return
                    }

                    // registerApp() returns whether request was accepted.
                    // Final registered state comes in onAppStatusChanged callback.
                    val regRes = registerAppApi31(hidDevice, hidSettings, deviceAddress)
                    result.success(regRes)
                }

                override fun onServiceDisconnected(profile: Int) {
                    _isServiceRunning = false
                    _isProfileRegistered = false
                    bluetoothHidDevice = null
                }
            },
            BluetoothProfile.HID_DEVICE
        )
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun registerAppApi31(
        hidDevice: BluetoothHidDevice,
        settings: BluetoothHidDeviceAppSdpSettings,
        deviceAddress: String
    ): Map<String, Any?> {

        if (!hasBluetoothConnectPermission()) {
            return resp(false, "Missing BLUETOOTH_CONNECT permission", "MISSING_PERMISSION")
        }

        return try {
            val accepted = hidDevice.registerApp(
                settings,
                null,
                null,
                Runnable::run,
                object : BluetoothHidDevice.Callback() {

                    override fun onAppStatusChanged(pluggedDevice: BluetoothDevice?, registered: Boolean) {
                        _isProfileRegistered = registered

                        // This is the actual "registered or not" truth.
                        // Optional: send event to Flutter so you can see it immediately.
                        try {
                            channel.invokeMethod(
                                "onAppStatusChanged",
                                resp(
                                    ok = registered,
                                    message = if (registered) "HID app registered" else "HID app NOT registered",
                                    code = if (registered) "HID_APP_REGISTERED" else "HID_APP_NOT_REGISTERED",
                                    details = mapOf(
                                        "pluggedDeviceAddress" to (pluggedDevice?.address ?: ""),
                                        "pluggedDeviceName" to (pluggedDevice?.name ?: "")
                                    )
                                )
                            )
                        } catch (_: Exception) {
                            // ignore event errors
                        }

                        if (registered && deviceAddress.isNotEmpty()) {
                            // auto-connect if an address was provided
                            val connectRes = connectDevice(deviceAddress)
                            try {
                                channel.invokeMethod("onAutoConnectResult", connectRes)
                            } catch (_: Exception) {
                                // ignore event errors
                            }
                        }
                    }

                    override fun onConnectionStateChanged(device: BluetoothDevice?, state: Int) {
                        _connectionState = mapOf(
                            "state" to state,
                            "deviceName" to (device?.name ?: ""),
                            "deviceAddress" to (device?.address ?: "")
                        )

                        // Optional: send event
                        try {
                            channel.invokeMethod(
                                "onConnectionStateChanged",
                                resp(
                                    ok = true,
                                    message = "Connection state changed: $state",
                                    code = "CONNECTION_STATE_CHANGED",
                                    details = _connectionState
                                )
                            )
                        } catch (_: Exception) {
                            // ignore event errors
                        }
                    }
                }
            )

            if (accepted) {
                resp(
                    ok = true,
                    message = "registerApp() accepted. Waiting for callback onAppStatusChanged for final registered state.",
                    code = "REGISTER_APP_ACCEPTED"
                )
            } else {
                resp(
                    ok = false,
                    message = "registerApp() returned false (request not accepted)",
                    code = "REGISTER_APP_REJECTED"
                )
            }

        } catch (e: Exception) {
            resp(
                ok = false,
                message = "registerApp() exception: ${e.message}",
                code = "REGISTER_APP_EXCEPTION",
                details = mapOf("exception" to e.toString())
            )
        }
    }

    // ----------------------------
    // Stop HID profile (name kept)
    // ----------------------------

    private fun stopHidProfile(): Map<String, Any?> {
        val hidDevice = bluetoothHidDevice
        if (hidDevice == null) {
            _isServiceRunning = false
            _isProfileRegistered = false
            _connectionState = mapOf("state" to 0, "deviceName" to "", "deviceAddress" to "")
            bluetoothDevice = null
            return resp(true, "HID profile already stopped", "ALREADY_STOPPED")
        }

        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                try {
                    // best-effort
                    disconnectDevice()
                    hidDevice.unregisterApp()
                } catch (_: Exception) {
                    // ignore, still close proxy
                }
            }

            bluetoothAdapter?.closeProfileProxy(BluetoothProfile.HID_DEVICE, hidDevice)

            bluetoothHidDevice = null
            bluetoothDevice = null
            _isServiceRunning = false
            _isProfileRegistered = false
            _connectionState = mapOf("state" to 0, "deviceName" to "", "deviceAddress" to "")

            resp(true, "HID profile stopped", "STOPPED")
        } catch (e: Exception) {
            resp(
                ok = false,
                message = "Failed to stop HID profile: ${e.message}",
                code = "STOP_FAILED",
                details = mapOf("exception" to e.toString())
            )
        }
    }

    // ----------------------------
    // Connect / Disconnect / Send report (names kept)
    // ----------------------------

    private fun connectDevice(deviceAddress: String): Map<String, Any?> {
        ensureBluetoothReady()?.let { return it }

        if (deviceAddress.isBlank()) {
            return resp(false, "deviceAddress is empty", "INVALID_ARGUMENT")
        }

        val hidDevice = bluetoothHidDevice
        if (hidDevice == null) {
            return resp(false, "HID profile not started. Call startHidProfile first.", "HID_NOT_READY")
        }

        if (!_isServiceRunning) {
            return resp(false, "HID service is not running", "SERVICE_NOT_RUNNING")
        }

        return try {
            bluetoothDevice = bluetoothAdapter?.getRemoteDevice(deviceAddress.uppercase(Locale.getDefault()))
            val dev = bluetoothDevice

            if (dev == null) {
                return resp(false, "Failed to create remote device from address", "REMOTE_DEVICE_NULL")
            }

            val ok = hidDevice.connect(dev)

            if (ok) {
                resp(
                    ok = true,
                    message = "Connect request sent to ${dev.address} (${dev.name ?: "Unknown"})",
                    code = "CONNECT_REQUESTED",
                    details = mapOf("deviceAddress" to dev.address, "deviceName" to (dev.name ?: ""))
                )
            } else {
                resp(
                    ok = false,
                    message = "connect() returned false (device may reject, not paired, or app not registered yet)",
                    code = "CONNECT_REJECTED",
                    details = mapOf("deviceAddress" to dev.address, "deviceName" to (dev.name ?: ""))
                )
            }
        } catch (e: IllegalArgumentException) {
            resp(
                ok = false,
                message = "Invalid MAC address format: ${e.message}",
                code = "INVALID_MAC",
                details = mapOf("deviceAddress" to deviceAddress)
            )
        } catch (e: Exception) {
            resp(
                ok = false,
                message = "Connect failed: ${e.message}",
                code = "CONNECT_EXCEPTION",
                details = mapOf("exception" to e.toString())
            )
        }
    }

    private fun disconnectDevice(): Map<String, Any?> {
        val hidDevice = bluetoothHidDevice
            ?: return resp(false, "HID profile not started", "HID_NOT_READY")

        val dev = bluetoothDevice
            ?: return resp(false, "No device to disconnect (bluetoothDevice is null)", "NO_DEVICE")

        return try {
            hidDevice.disconnect(dev)
            // (Your old code called disconnect twice; usually not needed, so we keep it once)
            bluetoothDevice = null

            resp(
                ok = true,
                message = "Disconnect request sent to ${dev.address} (${dev.name ?: "Unknown"})",
                code = "DISCONNECT_REQUESTED",
                details = mapOf("deviceAddress" to dev.address, "deviceName" to (dev.name ?: ""))
            )
        } catch (e: Exception) {
            resp(
                ok = false,
                message = "Disconnect failed: ${e.message}",
                code = "DISCONNECT_EXCEPTION",
                details = mapOf("exception" to e.toString())
            )
        }
    }

    private fun sendReport(reportId: Int, data: ByteArray): Map<String, Any?> {
        val hidDevice = bluetoothHidDevice
            ?: return resp(false, "HID profile not started", "HID_NOT_READY")

        val dev = bluetoothDevice
            ?: return resp(false, "No connected device. Connect first.", "NOT_CONNECTED")

        // Optional state check (STATE_CONNECTED == 2)
        val state = (_connectionState["state"] as? Int) ?: 0
        if (state != BluetoothProfile.STATE_CONNECTED) {
            return resp(
                ok = false,
                message = "Cannot send report: device is not in STATE_CONNECTED (state=$state)",
                code = "NOT_CONNECTED_STATE",
                details = mapOf("state" to state, "deviceAddress" to dev.address)
            )
        }

        return try {
            val ok = hidDevice.sendReport(dev, reportId, data)
            if (ok) {
                resp(
                    ok = true,
                    message = "Report sent (reportId=$reportId, bytes=${data.size})",
                    code = "REPORT_SENT",
                    details = mapOf("reportId" to reportId, "bytes" to data.size)
                )
            } else {
                resp(
                    ok = false,
                    message = "sendReport() returned false",
                    code = "REPORT_FAILED",
                    details = mapOf("reportId" to reportId, "bytes" to data.size)
                )
            }
        } catch (e: Exception) {
            resp(
                ok = false,
                message = "sendReport failed: ${e.message}",
                code = "REPORT_EXCEPTION",
                details = mapOf("exception" to e.toString())
            )
        }
    }
}
