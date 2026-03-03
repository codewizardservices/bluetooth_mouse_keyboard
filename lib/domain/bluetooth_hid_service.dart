import 'dart:async';
import 'dart:typed_data';

import 'package:bluetoothairmousekeyboard/domain/entities/enums.dart';
import 'package:bluetoothairmousekeyboard/domain/entities/remote_input/keyboard/keyboard_key.dart';
import 'package:flutter/services.dart';
import 'dart:math';

/// Matches the native Kotlin `resp(...)` shape:
/// {
///   "ok": true/false,
///   "message": "...",
///   "code": "...",
///   "details": { ... }
/// }
class HidResult {
  final bool ok;
  final String message;
  final String? code;
  final Map<String, dynamic> details;

  HidResult({
    required this.ok,
    required this.message,
    this.code,
    Map<String, dynamic>? details,
  }) : details = details ?? const {};

  factory HidResult.fromDynamic(dynamic raw) {
    if (raw is Map) {
      final map = Map<dynamic, dynamic>.from(raw);
      return HidResult(
        ok: map['ok'] == true,
        message: (map['message'] ?? '').toString(),
        code: map['code']?.toString(),
        details: map['details'] is Map
            ? Map<String, dynamic>.from(
                Map<dynamic, dynamic>.from(map['details']),
              )
            : <String, dynamic>{},
      );
    }
    return HidResult(
      ok: false,
      message: 'Unexpected native response: ${raw.runtimeType}',
      code: 'BAD_RESPONSE',
      details: {'raw': raw?.toString()},
    );
  }

  static HidResult fail(String code, String message, [Map<String, dynamic>? details]) {
    return HidResult(ok: false, code: code, message: message, details: details);
  }

  @override
  String toString() => 'HidResult(ok=$ok, code=$code, message=$message, details=$details)';
}

class BluetoothHidService {
  static const MethodChannel _channel =
      MethodChannel('com.smarttvmousekeyboard.bluetoothairmousekeyboard/bluetooth_hid');

  // ---- Shared static state (same across every object instance) ----

  /// True only when we receive STATE_CONNECTED event from native callback.
  static bool isConnected = false;

  /// Optional: track last connection details (name/address/state)
  static Map<String, dynamic> connectionState = <String, dynamic>{
    'state': 0,
    'deviceName': '',
    'deviceAddress': '',
  };

  /// Optional: store last native event/result for debugging
  static HidResult? lastEvent;
  static HidResult? lastError;

  // ---- Optional: event stream (also shared across instances) ----
  static final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Listen to native events if you want (onAppStatusChanged, onConnectionStateChanged, etc.)
  static Stream<Map<String, dynamic>> get events => _eventsController.stream;

  static bool _eventsInitialized = false;

  // Android BluetoothProfile constants (match native)
  static const int _STATE_DISCONNECTED = 0;
  static const int _STATE_CONNECTED = 2;

  /// Call once at app start (or before you start HID profile).
  /// Safe to call multiple times.
  static void initEvents() {
    if (_eventsInitialized) return;
    _eventsInitialized = true;

    _channel.setMethodCallHandler((MethodCall call) async {
      final HidResult payload = HidResult.fromDynamic(call.arguments);
      lastEvent = payload;

      // Keep the most important state in sync:
      // Kotlin sends "onConnectionStateChanged" with details containing:
      // { state, deviceName, deviceAddress }
      if (call.method == 'onConnectionStateChanged') {
        final d = payload.details;

        final int state = (d['state'] is int)
            ? d['state'] as int
            : int.tryParse('${d['state']}') ?? 0;

        connectionState = {
          'state': state,
          'deviceName': (d['deviceName'] ?? '').toString(),
          'deviceAddress': (d['deviceAddress'] ?? '').toString(),
        };

        if (state == _STATE_CONNECTED) {
          isConnected = true;
        } else if (state == _STATE_DISCONNECTED) {
          isConnected = false;
        } else {
          // other states (CONNECTING/DISCONNECTING) - leave as-is
        }
      }

      // If native says service disconnected, treat as not connected
      if (call.method == 'onHidServiceDisconnected') {
        isConnected = false;
      }

      // Expose all events to listeners (optional)
      _eventsController.add({
        'event': call.method,
        'ok': payload.ok,
        'code': payload.code,
        'message': payload.message,
        'details': payload.details,
      });
    });
  }

  // ---- Helpers ----

  Future<HidResult> _invokeResult(String method, [Map<String, dynamic>? args]) async {
    try {
      final raw = await _channel.invokeMethod<dynamic>(method, args);
      final r = HidResult.fromDynamic(raw);

      // Optional: cache last error
      if (!r.ok) lastError = r;

      // If bluetooth becomes OFF (native returns BLUETOOTH_DISABLED),
      // you said you will handle it yourself. Leave this here:
      if (r.code == 'BLUETOOTH_DISABLED') {
        // TODO: handle bluetooth turned off (show UI, prompt user, etc.)
      }

      // Missing permission hook too (optional)
      if (r.code == 'MISSING_PERMISSION') {
        // TODO: handle permission missing
      }

      return r;
    } catch (e) {
      lastError = HidResult.fail(
        'PLATFORM_EXCEPTION',
        'Platform error calling $method: $e',
        {'method': method, 'args': args},
      );
      return lastError!;
    }
  }

  // ---- Your public API (same method names as before) ----

  /// You will call this first.
  /// Note: native returns "REGISTER_APP_ACCEPTED" first; final registration arrives via event.
  Future<HidResult> startHidProfile({String deviceAddress = ''}) async {
    await stopHidProfile();
    BluetoothHidService.initEvents(); // ensure events are active
    final r = await _invokeResult('startHidProfile', {'deviceAddress': deviceAddress});
    return r;
  }

  Future<HidResult> stopHidProfile() async {
    final r = await _invokeResult('stopHidProfile');
    // Stopping profile means no connection
    if (r.ok) isConnected = false;
    return r;
  }

  /// You will call this after startHidProfile ok, OR rely on native auto-connect.
  Future<HidResult> connectDevice(String deviceAddress) async {
    final r = await _invokeResult('connectDevice', {'deviceAddress': deviceAddress});
    // Do NOT set isConnected here; wait for the native event (truth source).
    return r;
  }

  /// You said you won't call this usually, but you still want the service to know.
  Future<HidResult> disconnectDevice() async {
    final r = await _invokeResult('disconnectDevice');
    // If disconnect request succeeded, we can optimistically set false;
    // but the event will also update it.
    if (r.ok) isConnected = false;
    return r;
  }

  /// Your main usage:
  /// Only send if isConnected == true; otherwise return a descriptive result.
  Future<HidResult> sendReport(int reportId, List<int> data, {required String address}) async {
    // You asked: check a shared static isConnected, if false, do not call native.
    if (!BluetoothHidService.isConnected) {
      return HidResult.fail(
        'NOT_CONNECTED',
        'Cannot send report: device is not connected',
        {
          'connectionState': BluetoothHidService.connectionState,
          // address kept for your API compatibility; native doesn't use it in your Kotlin right now.
          'address': address,
          'reportId': reportId,
          'bytes': data.length,
        },
      );
    }

    final r = await _invokeResult('sendReport', {
      'reportId': reportId,
      'data': Uint8List.fromList(data),
    });

    // If sending fails with a "not connected" style code, update isConnected false (defensive)
    if (!r.ok && (r.code == 'NOT_CONNECTED' || r.code == 'NOT_CONNECTED_STATE')) {
      BluetoothHidService.isConnected = false;
    }

    return r;
  }



int _clamp127(int v) => max(-127, min(127, v));

Future<void> sendWheelScroll({
  required String address,
  required int wheelSteps, // positive/negative
}) async {
  final w = _clamp127(wheelSteps);

  // [buttons, x, y, wheel]
  final data = <int>[0x00, 0x00, 0x00, w];

  // IMPORTANT: use the mouse report id (your InputType.mouseMove.value)
  await sendReport(InputType.mouseMove.value, data, address: address);
}
  /// Native still returns a Map for connection state. This just reads it.
  /// (Your real-time connection should rely on the event + static vars.)
  Future<Map<String, dynamic>> getConnectionState() async {
    try {
      final raw =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('getConnectionState');
      final mapped = Map<String, dynamic>.from(raw ?? {});
      // keep static copy updated
      BluetoothHidService.connectionState = mapped;
      return mapped;
    } catch (_) {
      return {'state': 0, 'deviceName': '', 'deviceAddress': ''};
    }
  }

  Future<bool> isServiceRunning() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('isServiceRunning');
      return raw == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isProfileRegistered() async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('isProfileRegistered');
      return raw == true;
    } catch (_) {
      return false;
    }
  }

  /// Native Kotlin currently returns a HidResult(Map) for this (count + devices in details).
  Future<HidResult> getPairedDevices() async {
    final r = await _invokeResult('getPairedDevices');
    return r;
  }

  // Put inside BluetoothHidService


/// Wait for confirmed connected (STATE_CONNECTED) with a timeout.
/// Returns success/fail with full message.
Future<HidResult> waitUntilConnected({Duration timeout = const Duration(seconds: 8)}) async {
  BluetoothHidService.initEvents();

  // already connected?
  if (BluetoothHidService.isConnected) {
    return HidResult(
      ok: true,
      code: 'ALREADY_CONNECTED',
      message: 'Already connected',
      details: BluetoothHidService.connectionState,
    );
  }

  final completer = Completer<HidResult>();
  StreamSubscription? sub;

  // Optional: small poll fallback in case events are missed
  Timer? pollTimer;

  void finish(HidResult r) {
    if (completer.isCompleted) return;
    pollTimer?.cancel();
    sub?.cancel();
    completer.complete(r);
  }

  // Listen to native events
  sub = BluetoothHidService.events.listen((e) {
    if (e['event'] == 'onConnectionStateChanged') {
      final details = (e['details'] as Map?) ?? {};
      final state = details['state'];

      final intState = state is int ? state : int.tryParse('$state') ?? 0;

      if (intState == _STATE_CONNECTED) {
        finish(HidResult(
          ok: true,
          code: 'CONNECTED',
          message: 'Connected confirmed (STATE_CONNECTED)',
          details: Map<String, dynamic>.from(details),
        ));
      }
    }

    // If native says service disconnected, fail fast
    if (e['event'] == 'onHidServiceDisconnected') {
      finish(HidResult(
        ok: false,
        code: 'HID_SERVICE_DISCONNECTED',
        message: 'HID service disconnected while waiting to connect',
        details: Map<String, dynamic>.from((e['details'] as Map?) ?? {}),
      ));
    }
  });

  // Poll fallback (optional but helps a lot on some devices)
  pollTimer = Timer.periodic(const Duration(milliseconds: 400), (_) async {
    final state = await getConnectionState();
    final s = state['state'];
    final intState = s is int ? s : int.tryParse('$s') ?? 0;
    if (intState == _STATE_CONNECTED) {
      finish(HidResult(
        ok: true,
        code: 'CONNECTED',
        message: 'Connected confirmed (poll)',
        details: state,
      ));
    }
  });

  // Timeout
  Future.delayed(timeout, () async {
    if (completer.isCompleted) return;

    final state = await getConnectionState();
    finish(HidResult(
      ok: false,
      code: 'CONNECT_TIMEOUT',
      message: 'Timed out waiting for STATE_CONNECTED',
      details: {
        'lastKnownState': state,
        'isConnectedFlag': BluetoothHidService.isConnected,
      },
    ));
  });

  return completer.future;
}

/// Calls connectDevice() then waits for confirmed connection.
/// Use this instead of using CONNECT_REQUESTED as success.
Future<HidResult> connectAndWaitUntilConnected(
  String deviceAddress, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  BluetoothHidService.initEvents();

  final req = await connectDevice(deviceAddress);
  if (!req.ok) return req; // request itself failed (bad permission, HID not ready, etc.)

  // At this point req.code likely == CONNECT_REQUESTED
  // Now wait for actual connection confirmation:
  final confirmed = await waitUntilConnected(timeout: timeout);

  if (!confirmed.ok) {
    // Keep request details too (helps debugging)
    return HidResult(
      ok: false,
      code: confirmed.code,
      message: '${confirmed.message} (connect request was accepted)',
      details: {
        'connectRequest': {
          'ok': req.ok,
          'code': req.code,
          'message': req.message,
          'details': req.details,
        },
        'waitResult': {
          'ok': confirmed.ok,
          'code': confirmed.code,
          'message': confirmed.message,
          'details': confirmed.details,
        }
      },
    );
  }
  isConnected = true;
  return confirmed;
}

Future<HidResult> sendKeyLabel(String label, {required String address}) async {
  final hk = HidKeyMapper.fromLabel(label);
  if (hk == null) {
    return HidResult.fail('UNSUPPORTED_KEY', 'Unsupported key: $label', {'label': label});
  }

  const int reportId = 1; // Keyboard

  // IMPORTANT: Your descriptor expects ONLY 2 bytes: [modifier, keycode]
  final press = <int>[hk.modifier, hk.keycode];
  final r1 = await sendReport(reportId, press, address: address);
  if (!r1.ok) return r1;

  final release = <int>[0x00, 0x00];
  return await sendReport(reportId, release, address: address);
}


}
