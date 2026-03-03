// lib/screens/screen_premium.dart
import 'dart:io';
import 'package:bluetoothairmousekeyboard/dialogs/subscription_faq_dialog.dart';
import 'package:bluetoothairmousekeyboard/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Note: Ensure these imports match your actual file structure
import '../extra/constants.dart';
import 'InAppPurchaseProvider.dart';
import 'constant_inapps.dart';
import 'inapp_utils.dart';

class ScreenPremiumSubscription extends StatefulWidget {
  const ScreenPremiumSubscription({super.key});

  @override
  State<ScreenPremiumSubscription> createState() => _ScreenPremiumSubscriptionState();
}

class _ScreenPremiumSubscriptionState extends State<ScreenPremiumSubscription> with WidgetsBindingObserver {
  final Color accentColor = AppThemeColors.accentCyan;
  final Color surfaceColor = const Color(0xFF1A1C1E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<InAppPurchaseProvider>(context, listen: false).initialize(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0B0C0F);
    
    return Consumer<InAppPurchaseProvider>(
      builder: (context, iapProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (Platform.isAndroid)
                TextButton(
                  onPressed: () => showDialog(context: context, builder: (_) => const SubscriptionFaqDialog()),
                  child: const Text("FAQ", style: TextStyle(color: Colors.white70)),
                )
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildPlansList(iapProvider),
                        const SizedBox(height: 20),
                        _buildTermsOfUse(context),
                      ],
                    ),
                  ),
                ),
                _buildActionFooter(iapProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Container(
        //   padding: const EdgeInsets.all(15),
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     color: accentColor.withOpacity(0.1),
        //   ),
        //   child: Icon(Icons.auto_awesome, color: accentColor, size: 40),
        // ),
        // const SizedBox(height: 16),
        const Text(
          'Go Premium',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Enjoy an ad-free experience and support the developer.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildPlansList(InAppPurchaseProvider provider) {
    if (provider.isLoadingProducts) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00)));
    }
    
    return Column(
      children: provider.availablePlans.map((plan) {
        bool isSelected = provider.selectedProductId == plan.id;
        bool isActive = provider.isPremiumUser && plan.id == provider.activePremiumProductId;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPlanCard(
            plan: plan,
            isSelected: isSelected,
            isActive: isActive,
            onTap: () => provider.selectPlan(plan.id),
          ),
        );
      }).toList(),
    );
  }

Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required bool isSelected,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    // Logic to determine "Best Value" (usually yearly)
    bool isBestValue = plan.title.toLowerCase().contains('year');

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF222428) : const Color(0xFF16181D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? accentColor : Colors.white.withOpacity(0.05),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Radio indicator for selection
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? accentColor : Colors.white30,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? accentColor : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Plan Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive ? "Current Active Plan" : "Ads removed + Premium features",
                        style: TextStyle(
                          color: isActive ? Colors.greenAccent : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price "Button" Design
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plan.displayPrice,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // "Best Value" Badge
          if (isBestValue)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "BEST VALUE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
    Widget _buildActionFooter(InAppPurchaseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: provider.isPurchasing ? null : () => provider.buyProduct(),
              child: Text(
                provider.isPurchasing ? "PROCESSING..." : "SUBSCRIBE NOW",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: provider.restorePurchases,
                child: const Text("Restore Purchase", style: TextStyle(color: Colors.white54)),
              ),
              const Text("|", style: TextStyle(color: Colors.white10)),
              TextButton(
                onPressed: () => _manageSubscriptions(),
                child: const Text("Manage Plan", style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _manageSubscriptions() {
    final url = Platform.isIOS
        ? 'itms-apps://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions';
    Constants.openUrlSite(context, url);
  }

  Widget _buildTermsOfUse(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text("Terms & Conditions", style: TextStyle(color: Colors.white70, fontSize: 13)),
        children: [getSubscriptionInfoView()],
      ),
    );
  }
}