import 'package:bluetoothairmousekeyboard/domain/entities/device_entity.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/ScreenPremiumSubscription.dart';
import 'package:bluetoothairmousekeyboard/screens/bluetooth_activation_screen.dart';
import 'package:bluetoothairmousekeyboard/screens/feedback_screen.dart';
import 'package:bluetoothairmousekeyboard/screens/how_to_use_screen.dart';
import 'package:bluetoothairmousekeyboard/screens/paired_devices_screen.dart';
import 'package:bluetoothairmousekeyboard/screens/remote_screen.dart';

import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: Routes.bluetoothActivation,
  routes: [
    GoRoute(
      path: Routes.remoteScreen,
      builder: (context, state) {
        final device = state.extra as DeviceEntity;
        return RemoteScreen(device: device);
      },
    ),
    GoRoute(
      path: Routes.bluetoothActivation,
      builder: (context, state) => const BluetoothActivationScreen(),
    ),
    GoRoute(
      path: Routes.pairedDevices,
      builder: (context, state) => const PairedDevicesScreen(),
    ),
    GoRoute(
      path: Routes.howToUse,
      builder: (context, state) => const HowToUseScreen(),
    ),
    GoRoute(
      path: Routes.feedback,
      builder: (context, state) => const FeedbackScreen(),
    ),
GoRoute(
      path: Routes.subscription,
      builder: (context, state) => const ScreenPremiumSubscription(),
    ),
  ],
);

class Routes {
  static const String splashscreen = '/splash';
  static const String feedback = '/feedback';
  static const String howToUse = '/how-to-use';
  static const String bluetoothActivation = '/bluetooth-activation';
  static const String pairedDevices = '/paired-devices';
  static const String remoteScreen = '/remote-screen';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
}
