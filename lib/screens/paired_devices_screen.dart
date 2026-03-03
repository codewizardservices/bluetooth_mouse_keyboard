import 'dart:io';

import 'package:bluetoothairmousekeyboard/admob/ad_state_provider.dart';
import 'package:bluetoothairmousekeyboard/admob/appopen_ad_helper.dart';
import 'package:bluetoothairmousekeyboard/admob/interstitial_ad_helper.dart';
import 'package:bluetoothairmousekeyboard/admob/native_ad_video_helper.dart';
import 'package:bluetoothairmousekeyboard/dialogs/message_dialog.dart';
import 'package:bluetoothairmousekeyboard/domain/bluetooth_hid_service.dart';
import 'package:bluetoothairmousekeyboard/domain/entities/device_entity.dart';
import 'package:bluetoothairmousekeyboard/extra/pressable.dart';
import 'package:bluetoothairmousekeyboard/extra/utilites.dart';
import 'package:bluetoothairmousekeyboard/routes.dart';
import 'package:bluetoothairmousekeyboard/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum HeaderMenu { feedback, howToUse, rateUs, shareApp, policy }

class PairedDevicesScreen extends StatefulWidget {
  const PairedDevicesScreen({super.key});

  @override
  State<StatefulWidget> createState() => PairedDevicesScreenState();
}

class PairedDevicesScreenState extends State<PairedDevicesScreen> {
  // UI State
  List<DeviceEntity> _devices = [];
  String? _connectingAddress;
  bool _isLoadingList = false;

  // Services
  final BluetoothHidService _hidService = BluetoothHidService();
  DeviceEntity currentDevice = DeviceEntity(address: 'address', name: 'name');

  final InterstitialAdHelper interstitialAdHelper = InterstitialAdHelper();
    final NativeVideoAdHelper _nativeAdHelper = NativeVideoAdHelper();


  @override
  void initState() {
    super.initState();
    _nativeAdHelper.loadNativeAd(() => setState(() {}));

    interstitialAdHelper.loadInterstitialAds(
      onAdDismissed: () {
        Future.delayed(const Duration(seconds: 30), () {
          MyAppState().updateValue(false); // enable open ads after 30 sec
        });
        doNextFunctionality();
      },
      onAdShowFullScreen: () {
        MyAppState().updateValue(true); // disabled app open ads
      },
    );

    BluetoothHidService.initEvents();
    _fetchPairedDevices();
  }

  @override
  void dispose() {
        _nativeAdHelper.dispose();

    interstitialAdHelper.dispose();
    super.dispose();
  }

  void doNextFunctionality() {
    if (!mounted) return;
    _connectToDevice(currentDevice);
  }

  Future<void> _fetchPairedDevices() async {
    setState(() => _isLoadingList = true);

     if (!_nativeAdHelper.isLoaded) {
      await Future.delayed(Duration(seconds: 4));
    }

    try {
      final status = await Permission.bluetoothConnect.request();
      if (!status.isGranted) {
        throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Bluetooth permissions not granted',
        );
      }

      final rawData = await _hidService.getPairedDevices();
      final devicesRaw = (rawData.details['devices'] as List?) ?? [];

      final devices = devicesRaw
          .map((e) => Map<String, String>.from(e as Map))
          .toList();

      if (mounted) {
        setState(() {
          _devices = devices
              .map(
                (d) => DeviceEntity(
                  name: d['name'] ?? 'Unknown',
                  address: d['address'] ?? '',
                ),
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching devices: $e");
    } finally {
      if (mounted) setState(() => _isLoadingList = false);
    }
  }

  Future<void> _connectToDevice(DeviceEntity device) async {
    if (_connectingAddress != null) return;

    setState(() => _connectingAddress = device.address);

    try {
      await _hidService.startHidProfile(deviceAddress: device.address);

      final connected = await _hidService.connectAndWaitUntilConnected(
        device.address,
        timeout: const Duration(seconds: 10),
      );

      if (!mounted) return;

      if (connected.ok) {
        BluetoothHidService.isConnected = true;
        context.go(Routes.remoteScreen, extra: device);
      } else {
        showDialogMessage(
          context: context,
          title: "Unable to Connect",
          barrierDismissible: true,
          message:
              "Please restart your device’s Bluetooth. Then restart the application and try again.",
          buttonText: 'Done',
        );
      }
    } catch (e) {
      _showSnackBar('Connection error: $e');
    } finally {
      if (mounted) setState(() => _connectingAddress = null);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onHeaderMenuSelected(HeaderMenu item) {
    switch (item) {
      case HeaderMenu.feedback:
        context.push(Routes.feedback);
        break;
      case HeaderMenu.howToUse:
        context.push(Routes.howToUse);
        break;
      case HeaderMenu.rateUs:
        Utilites.rateUs();
        break;
      case HeaderMenu.shareApp:
        Utilites.shareApp();
        break;
      case HeaderMenu.policy:
        Utilites.openPrivacyPolicy();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !Platform.isAndroid,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        bottomNavigationBar: SafeArea(
          child: Consumer<AdStateProvider>(
            builder: (context, provider, child) {
              // If subscribed, show nothing. Otherwise, show the ad.
              return provider.isSubscribed
                  ? const SizedBox.shrink()
                  : _nativeAdHelper.buildAdWidgetContainer();
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                AppThemeColors.bgTop,
                AppThemeColors.bgMid,
                AppThemeColors.bgBottom,
              ],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchPairedDevices,
              color: AppThemeColors.accentCyan,
              backgroundColor: AppThemeColors.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 14),
                    _buildInfoBanner(context),
                    const SizedBox(height: 14),
                    Expanded(
                      child: _devices.isEmpty
                          ? _buildEmptyState()
                          : _buildDeviceList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Bluetooth Devices',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Select TV device to connect',
                style: TextStyle(
                  color: AppThemeColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // PRO (kept, but styled to match neon theme)
        // todo : change agian to subscription 
        // _ProChip(onTap: () => context.push(Routes.subscription)),
        _ProChip(onTap: () => context.push(Routes.remoteScreen, extra: DeviceEntity(address: 'address', name: 'name'))),

        const SizedBox(width: 8),

        // Menu
        PopupMenuButton<HeaderMenu>(
          onSelected: _onHeaderMenuSelected,
          color: AppThemeColors.surface,
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: HeaderMenu.feedback,
              child: _MenuRow(icon: Icons.mail, label: 'Feedback'),
            ),
            PopupMenuItem(
              value: HeaderMenu.howToUse,
              child: _MenuRow(icon: Icons.help_outline, label: 'How to use'),
            ),
            PopupMenuItem(
              value: HeaderMenu.rateUs,
              child: _MenuRow(icon: Icons.star_rate_rounded, label: 'Rate us'),
            ),
            PopupMenuItem(
              value: HeaderMenu.shareApp,
              child: _MenuRow(icon: Icons.share, label: 'Share app'),
            ),
            PopupMenuItem(
              value: HeaderMenu.policy,
              child: _MenuRow(icon: Icons.privacy_tip_outlined, label: 'Policy'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemeColors.surface.withOpacity(0.85),
            AppThemeColors.surface.withOpacity(0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeColors.accentCyan.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 12),
            color: Colors.black.withOpacity(0.35),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppThemeColors.accentCyan, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Pair devices in Bluetooth settings to see them here.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          _MiniOutlineButton(
            label: 'Scan',
            icon: Icons.refresh,
            onTap: _fetchPairedDevices,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppThemeColors.surface.withOpacity(0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeColors.stroke.withOpacity(0.7)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLoadingList ? Icons.sync : Icons.tv_rounded,
              color: Colors.white.withOpacity(0.55),
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              _isLoadingList ? 'Syncing devices…' : 'No paired devices found',
              style: const TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_isLoadingList) ...[
              const SizedBox(height: 10),
              _MiniOutlineButton(
                label: 'Refresh',
                icon: Icons.refresh,
                onTap: _fetchPairedDevices,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 6),
      itemCount: _devices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final device = _devices[index];
        final isConnecting = _connectingAddress == device.address;

        return Pressable(
          onTap: () {
            currentDevice = device;
            interstitialAdHelper.showAdIfAvailable(doNextFunctionality);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeColors.card.withOpacity(0.95),
                  AppThemeColors.surface.withOpacity(0.70),
                ],
              ),
              border: Border.all(
                color: (isConnecting
                        ? AppThemeColors.accentCyan
                        : AppThemeColors.stroke)
                    .withOpacity(isConnecting ? 0.55 : 0.85),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                  color: Colors.black.withOpacity(0.40),
                ),
                if (isConnecting)
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 0),
                    color: AppThemeColors.accentCyan.withOpacity(0.12),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppThemeColors.accentCyan.withOpacity(0.22),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: AppThemeColors.accentCyan.withOpacity(0.20),
                    ),
                  ),
                  child: const Icon(Icons.tv_rounded,
                      color: Colors.white70, size: 20),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppThemeColors.textSecondary.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isConnecting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppThemeColors.accentCyan,
                    ),
                  )
                else
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _MiniOutlineButton extends StatelessWidget {
  const _MiniOutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppThemeColors.accentCyan.withOpacity(0.35),
            ),
            color: AppThemeColors.surface.withOpacity(0.35),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppThemeColors.accentCyan),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppThemeColors.accentCyan,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProChip extends StatelessWidget {
  const _ProChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppThemeColors.accentOrange.withOpacity(0.95),
                const Color(0xFFFF9E1F),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppThemeColors.accentOrange.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.diamond_outlined, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}