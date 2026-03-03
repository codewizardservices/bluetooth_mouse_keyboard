import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppConstantsView {
  static const SELECT_YOUR_SUBSCRIPTION_PLAN = Padding(
    padding: const EdgeInsets.all(8.0),
    child: const Text(
      "SELECT YOUR SUBSCRIPTION PLAN",
      style: TextStyle(
        color: InAppConstants.textColorBlack,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
  static const decoration = BoxDecoration(
    color: InAppConstants.lightGreyBackground,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(
        InAppConstants.cardBorderRadius * 2,
      ), // Larger radius for top corners
      topRight: Radius.circular(InAppConstants.cardBorderRadius * 2),
      bottomLeft: Radius.circular(InAppConstants.cardBorderRadius * 2),
      bottomRight: Radius.circular(InAppConstants.cardBorderRadius * 2),
    ),
  );
}

class InAppConstants {
  static const double defaultPadding = 10.0;
  static const double screenHorizontalPadding = 10.0;
  static const double screenVerticalPadding =
      10.0; // Changed from top: 10, bottom: 5

  static const double largeButtonHeight = 45.0;
  static const double smallButtonHeight = 40.0; // Adjusted for small buttons
  static const double smallButtonRadius = 20.0; // <--- ADD THIS LINE
  static const double buttonBorderRadius = 30.0;
  static const double cardBorderRadius = 10.0;
  static const double premiumHeaderHeight = 45.0;

  // Animation Durations
  static const Duration logoAnimationDuration = Duration(seconds: 1);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 800);

  // Colors
  static const Color primaryPurple = Colors.purple;
  static const Color deepPurple = Colors.deepPurple;
  static const Color lightGreyBackground = Color(0xFFF5F5F5);
  static const Color unselectedBorderColor = Colors.white60;
  static const Color selectedBorderColor = InAppConstants.primaryPurple;
  static const Color textColorBlack = Colors.black;
  static const Color textColorWhite = Colors.white;
}

enum GradientButtonType { large, small }

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GradientButtonType type;
  final List<Color> gradientColors;
  final TextStyle? textStyle;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = GradientButtonType.large,
    this.gradientColors = const [
      InAppConstants.primaryPurple,
      InAppConstants.deepPurple,
    ],
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? height;
    EdgeInsetsGeometry? padding;
    double borderRadius;
    TextStyle defaultTextStyle;

    switch (type) {
      case GradientButtonType.large:
        height = InAppConstants.largeButtonHeight;
        borderRadius = InAppConstants.buttonBorderRadius;
        defaultTextStyle = const TextStyle(
          color: InAppConstants.textColorWhite,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        );
        break;
      case GradientButtonType.small:
        padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20);
        borderRadius = InAppConstants.smallButtonRadius;
        defaultTextStyle = const TextStyle(
          color: InAppConstants.textColorWhite,
          fontSize: 14,
        );
        break;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height, // Null for small, container will size based on padding
        width:
            type == GradientButtonType.large
                ? double.infinity
                : null, // Fill width for large
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(colors: gradientColors),
        ),
        alignment: Alignment.center,
        child: Text(text, style: textStyle ?? defaultTextStyle),
      ),
    );
  }
}

class PremiumHeaderButton extends StatelessWidget {
  final VoidCallback? onClosePressed;
  final VoidCallback? onPolicyPressed;
  final String buttonText;
  final List<Color> gradientColors;

  const PremiumHeaderButton({
    Key? key,
    this.onClosePressed,
    this.onPolicyPressed,
    this.buttonText = "GET PREMIUM",
    this.gradientColors = const [
      InAppConstants.primaryPurple,
      InAppConstants.deepPurple,
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: InAppConstants.premiumHeaderHeight,
      child: Stack(
        children: [
          // Get Premium Button
          Container(
            width: double.infinity,
            height: InAppConstants.premiumHeaderHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                InAppConstants.buttonBorderRadius,
              ),
              gradient: LinearGradient(colors: gradientColors),
            ),
            alignment: Alignment.center,
            child: Text(
              buttonText,
              style: const TextStyle(
                color: InAppConstants.textColorWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Left Icon (Close)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: InAppConstants.textColorWhite,
              ),
              onPressed: onClosePressed,
            ),
          ),

          // Right Icon (Info)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(
                Icons.policy,
                color: InAppConstants.textColorWhite,
              ),
              onPressed: onPolicyPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final ValueChanged<String> onTap;
  final bool isPurchasedPlan; // NEW: Added property

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.isPurchasedPlan = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    // Use your defined constants
    Color borderColor =
        isSelected
            ? InAppConstants.selectedBorderColor
            : InAppConstants.unselectedBorderColor;
    Color bgColor =
        isSelected
            ? InAppConstants.primaryPurple.withOpacity(0.1)
            : InAppConstants.textColorWhite;

    if (isPurchasedPlan) {
      // Apply special styling if purchased
      borderColor =
          Colors
              .green; // You can define a specific green in InAppConstants if desired
      bgColor = Colors.green.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () => onTap(plan.id),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(InAppConstants.cardBorderRadius),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          // Use Stack to position the "Purchased" badge
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: InAppConstants.textColorBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: InAppConstants.textColorBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      plan.displayPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: InAppConstants.textColorBlack,
                      ),
                    ),
                    // Check if productDetails and freeTrialPeriod are not null/empty
                    // if (plan.productDetails.subscriptionOfferDetails != null &&
                    //     plan
                    //         .productDetails
                    //         .subscriptionOfferDetails!
                    //         .isNotEmpty &&
                    //     plan
                    //             .productDetails
                    //             .subscriptionOfferDetails!
                    //             .first
                    //             .freeTrialPeriod !=
                    //         null)
                    //   Padding(
                    //     padding: const EdgeInsets.only(left: 8.0),
                    //     child: Text(
                    //       'Free trial: ${plan.productDetails.subscriptionOfferDetails!.first.freeTrialPeriod}',
                    //       style: const TextStyle(
                    //         fontSize: 12,
                    //         color:
                    //             InAppConstants
                    //                 .textColorBlack, // Use existing color, or define a grey
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ],
            ),
            if (isPurchasedPlan) // Display "Purchased" badge
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(
                        InAppConstants.cardBorderRadius,
                      ),
                      bottomLeft: Radius.circular(
                        InAppConstants.cardBorderRadius / 2,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Purchased',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionPlan {
  final String id; // Product ID from App Store/Play Store
  final String title; // Localized title from IAP
  final String description; // Localized description from IAP
  String displayPrice; // Localized price string from IAP
  ProductDetails? productDetails; // To store the actual fetched product details

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.description,
    this.displayPrice = "Loading...", // Default while loading
    this.productDetails,
  });

  // Factory constructor to create a SubscriptionPlan from ProductDetails
  factory SubscriptionPlan.fromProductDetails(ProductDetails details) {
    return SubscriptionPlan(
      id: details.id,
      title: details.title,
      description: details.description,
      displayPrice: details.price, // Use the localized price
      productDetails: details,
    );
  }
}
