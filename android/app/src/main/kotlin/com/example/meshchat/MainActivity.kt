package com.example.meshchat

import android.bluetooth.*
import android.content.Context
import android.os.Build
import android.os.ParcelUuid
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val methodChannelName = "meshchat/gatt_server"
    private val eventChannelName = "meshchat/gatt_events"

    private var gattServer: BluetoothGattServer? = null
    private var bluetoothManager: BluetoothManager? = null
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var dataCharacteristic: BluetoothGattCharacteristic? = null
    private var controlCharacteristic: BluetoothGattCharacteristic? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "startServer" -> {
                        val service = UUID.fromString(call.argument<String>("service"))
                        val data = UUID.fromString(call.argument<String>("data"))
                        val control = UUID.fromString(call.argument<String>("control"))
                        try {
                            startGattServer(service, data, control)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("start_failed", e.message, null)
                        }
                    }
                    "stopServer" -> {
                        stopGattServer()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startGattServer(serviceUuid: UUID, dataUuid: UUID, controlUuid: UUID) {
        val ctx: Context = applicationContext
        bluetoothManager = ctx.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter
        if (bluetoothAdapter == null || !bluetoothAdapter!!.isEnabled) {
            throw IllegalStateException("Bluetooth adapter not enabled")
        }
        gattServer?.close()
        gattServer = bluetoothManager?.openGattServer(ctx, object : BluetoothGattServerCallback() {
            override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
                super.onConnectionStateChange(device, status, newState)
            }

            override fun onCharacteristicWriteRequest(
                device: BluetoothDevice,
                requestId: Int,
                characteristic: BluetoothGattCharacteristic,
                preparedWrite: Boolean,
                responseNeeded: Boolean,
                offset: Int,
                value: ByteArray
            ) {
                if (characteristic.uuid == dataUuid) {
                    eventSink?.success(value)
                }
                if (responseNeeded) {
                    gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
                }
            }
        })

        val service = BluetoothGattService(serviceUuid, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        dataCharacteristic = BluetoothGattCharacteristic(
            dataUuid,
            BluetoothGattCharacteristic.PROPERTY_WRITE or BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )
        controlCharacteristic = BluetoothGattCharacteristic(
            controlUuid,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ
        )
        service.addCharacteristic(dataCharacteristic)
        service.addCharacteristic(controlCharacteristic)
        gattServer?.addService(service)

        // Optional: set advertised service UUID for some stacks
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                val settings = android.bluetooth.le.AdvertiseSettings.Builder()
                    .setAdvertiseMode(android.bluetooth.le.AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
                    .setTxPowerLevel(android.bluetooth.le.AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
                    .setConnectable(true)
                    .build()
                val data = android.bluetooth.le.AdvertiseData.Builder()
                    .addServiceUuid(ParcelUuid(serviceUuid))
                    .setIncludeDeviceName(true)
                    .build()
                bluetoothAdapter?.bluetoothLeAdvertiser?.startAdvertising(settings, data, object : android.bluetooth.le.AdvertiseCallback() {})
            } catch (_: Exception) { }
        }
    }

    private fun stopGattServer() {
        try { gattServer?.close() } catch (_: Exception) {}
        gattServer = null
    }
}
