import 'package:flutter/material.dart';

class BlutoothPremiumDialog extends StatelessWidget {
  final VoidCallback onWatchAd;
  final VoidCallback onPurchasePremium;

  const BlutoothPremiumDialog({
    super.key,
    required this.onWatchAd,
    required this.onPurchasePremium,
  });

  @override
  Widget build(BuildContext context) {
    // --- Dark Theme Color Palette ---
    const Color lgRed = Color(0xFFFF5A1F);
    const Color surfaceColor = Color(0xFF1A1A1A); // Deep Charcoal
    const Color cardColor = Color(0xFF242424);    // Slightly lighter for the container
    const Color titleColor = Color(0xFFFFFFFF);   // Pure White
    const Color bodyColor = Color(0xFFB0B0B0);    // Light Grey
    const Color shadowLight = Color(0xFF323232);  // Subtle highlight for dark neumorphism

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            // Darker, heavier shadow for the bottom
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(8, 8),
              blurRadius: 20,
            ),
            // Very subtle highlight on top-left to maintain depth
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              offset: const Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.lock_person_rounded,
                size: 52,
                color: lgRed,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Unlock Content",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Purchase premium or watch an ad to open this.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: bodyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 36),

            Row(
              children: [
                // Button 1: Purchase (Primary)
                Expanded(
                  child: _buildButton(
                    label: "PREMIUM",
                    isPrimary: true,
                    onTap: onPurchasePremium,
                    surfaceColor: cardColor,
                    activeColor: lgRed,
                    shadowLight: shadowLight,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Button 2: Watch Ad (Outline/Secondary)
                Expanded(
                  child: _buildButton(
                    label: "WATCH AD",
                    isPrimary: false,
                    onTap: onWatchAd,
                    surfaceColor: cardColor,
                    activeColor: lgRed,
                    shadowLight: shadowLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color activeColor,
    required Color shadowLight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [activeColor, activeColor.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary ? null : surfaceColor,
          borderRadius: BorderRadius.circular(25),
          border: isPrimary ? null : Border.all(color: Colors.white10, width: 1), // Subtle border for dark mode
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    offset: const Offset(0, 6),
                    blurRadius: 15,
                  ),
                ]
              : [
                  // Neumorphic dark shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: shadowLight.withOpacity(0.3),
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : activeColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}