import 'dart:io';

import 'package:bluetoothairmousekeyboard/dialogs/message_dialog.dart';
import 'package:bluetoothairmousekeyboard/domain/bluetooth_hid_service.dart';
import 'package:bluetoothairmousekeyboard/domain/entities/device_entity.dart';
import 'package:bluetoothairmousekeyboard/domain/entities/enums.dart';
import 'package:bluetoothairmousekeyboard/domain/entities/remote_input/remote_input.dart';
import 'package:bluetoothairmousekeyboard/extra/utilites.dart';
import 'package:bluetoothairmousekeyboard/pages/keyboard_page.dart';
import 'package:bluetoothairmousekeyboard/pages/touchpad_page.dart';
import 'package:bluetoothairmousekeyboard/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RemoteScreen extends StatefulWidget {
  final DeviceEntity device;

  const RemoteScreen({super.key, required this.device});

  @override
  State<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  final BluetoothHidService _hidService = BluetoothHidService();

  Future<void> _sendRemoteInput(
    List<int> input, {
    InputType intputType = InputType.remoteInput,
    bool sendRelease = true,
  }) async {
    final result = await _hidService.sendReport(
      intputType.value,
      input,
      address: widget.device.address,
    );
    debugPrint('send report result $result');

    if (!result.ok) {
      await _disconnect();
      final started = await _hidService.startHidProfile(
        deviceAddress: widget.device.address,
      );
      Utilites.showSnackBar(context: context, text: "Connecting, Please wait");
      final r = await _hidService.connectAndWaitUntilConnected(
        widget.device.address,
      );
      if (!r.ok) {
        showDialogMessage(
          context: context,
          title: "Unable to Connect",
          barrierDismissible: true,
          message:
              "Please restart your device’s Bluetooth. Then restart the application and try again.",
          buttonText: 'Dones',
        );

        debugPrint('restart bluetooth');
      } else if (r.ok) {
        Utilites.showSnackBar(context: context, text: "Connected");
      }
    }

    if (intputType == InputType.remoteInput && sendRelease) {
      await _hidService.sendReport(intputType.value, [
        0x00,
        0,
        0,
        0,
      ], address: widget.device.address);
    }
  }

  Future<void> _disconnect() async {
    await _hidService.disconnectDevice();
    await _hidService.stopHidProfile();
  }

  int _index = 0;

  // Touchpad only (keyboard will be fullscreen route)
  // final _pages = const [TouchpadPage(), SizedBox.shrink()];

  @override
  void initState() {
    _setPortrait();
    super.initState();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  HomeTab _currentTab = HomeTab.touchpad;

  Future<void> _setPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _setLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _onTab(int next) async {
    if (next == 1) {
      setState(() => _currentTab = HomeTab.keyboard);
      await _setLandscape(); // optional (keyboard mode)
      return;
    }

    setState(() => _currentTab = HomeTab.touchpad);
    await _setPortrait();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !Platform.isAndroid,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          if (_currentTab != HomeTab.touchpad) {
            setState(() {
              _currentTab = HomeTab.touchpad;
            });
            return;
          }

          context.go(Routes.pairedDevices);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _currentTab.v,
            children: [
              TouchpadPage(
                onBack: () {
                  context.go(Routes.pairedDevices);
                },
                onLeftClick: () {
                  _sendRemoteInput(
                    RemoteInput.left,
                    intputType: InputType.mouseMove,
                  );
                  Future.delayed(Duration(microseconds: 200));
                  // mouse button up
                  _sendRemoteInput(
                    RemoteInput.releaseClick,
                    sendRelease: false,
                  );
                },
                onRightClick: () {
                  _sendRemoteInput(
                    RemoteInput.right,
                    intputType: InputType.mouseMove,
                  );
                  Future.delayed(Duration(microseconds: 200));
                  // mouse button up
                  _sendRemoteInput(
                    RemoteInput.releaseClick,
                    sendRelease: false,
                  );
                },
                sendReport: (report) {
                  _sendRemoteInput(report, intputType: InputType.mouseMove);
                },
                onScroll: (steps) async {
                  // your wheel report function here:
                  // steps can be + or -
                  await _hidService.sendWheelScroll(
                    address: widget.device.address,
                    wheelSteps: steps, // or -steps if direction feels inverted
                  );
                },
                onTwoFingerActive: (active) {
                  // optional: show indicator, etc.
                  debugPrint('Two finger: $active');
                },
              ),
              KeyboardPage(
                onKeyPressed: (key) {
                  print(key);
                  if (key == "ENTER") {
                    _hidService.sendKeyLabel(
                      "ENTER",
                      address: widget.device.address,
                    );
                    return;
                  }

                  if (key == "DEL") {
                    _hidService.sendKeyLabel(
                      "BACKSPACE",
                      address: widget.device.address,
                    );
                    return;
                  }

                  if (key == " ") {
                    _hidService.sendKeyLabel(
                      "SPACE",
                      address: widget.device.address,
                    );
                    return;
                  }

                  // normal character (a, A, 1, @, etc.)
                  _hidService.sendKeyLabel(key, address: widget.device.address);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTab.v,
          onDestinationSelected: _onTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.touch_app_outlined),
              selectedIcon: Icon(Icons.touch_app),
              label: 'Touchpad',
            ),
            NavigationDestination(
              icon: Icon(Icons.keyboard_alt_outlined),
              selectedIcon: Icon(Icons.keyboard_alt),
              label: 'Keyboard',
            ),
          ],
        ),
      ),
    );
  }
}

enum HomeTab {
  touchpad(0),
  keyboard(1);

  final int v;
  const HomeTab(this.v);
}