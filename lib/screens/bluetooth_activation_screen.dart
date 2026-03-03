import 'dart:async';

import 'package:bluetoothairmousekeyboard/extra/glowingorangebluetoothbutton.dart';
import 'package:bluetoothairmousekeyboard/routes.dart';
import 'package:bluetoothairmousekeyboard/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';


class BluetoothActivationScreen extends StatefulWidget {
  const BluetoothActivationScreen({super.key});

  @override
  State<BluetoothActivationScreen> createState() =>
      _BluetoothActivationScreenState();
}

class _BluetoothActivationScreenState extends State<BluetoothActivationScreen> {
  bool _isBluetoothEnabled = false;
  bool _isChecking = true;

  StreamSubscription<BluetoothAdapterState>? _adapterSub;

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (!mounted) return;

      setState(() {
        _isBluetoothEnabled = adapterState == BluetoothAdapterState.on;
        _isChecking = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isChecking = false;
      });
    }

    // Listen for Bluetooth state changes
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;

      setState(() {
        _isBluetoothEnabled = state == BluetoothAdapterState.on;
      });
    });
  }

  Future<void> _enableBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enable Bluetooth: $e')),
      );
    }
  }

  @override
  void dispose() {
    _adapterSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const backgroundColor = Color(0xFF0B0C0F);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Bluetooth Tv Remote Control',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isBluetoothEnabled
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  size: 60,
                  color: _isBluetoothEnabled
                      ? AppThemeColors.accentCyan
                      : Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  _isBluetoothEnabled
                      ? 'Bluetooth is Enabled'
                      : 'Bluetooth is Disabled',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  _isBluetoothEnabled
                      ? 'You can now Discover Devices'
                      : 'Please Enable Bluetooth to Continue',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (!_isBluetoothEnabled)
                  GlowingOrangeButton(
                    onPressed: _enableBluetooth,
                    text: 'Enable Bluetooth',
                    iconData: Icons.bluetooth,
                  ),
                if (_isBluetoothEnabled)
                  GlowingOrangeButton(
                    onPressed: () => context.replace(Routes.pairedDevices),
                    text: 'Discover Devices',
                    iconData: Icons.search,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
