import 'dart:io';

const String iosSharedSecret = '';
const String bundleId = '';

final List<String> productids = [
  // SubscriptionProductIDs.Adfree,
  // SubscriptionProductIDs.Intersfree,
  SubscriptionProductIDs.WeeklySubscription,
  SubscriptionProductIDs.MonthlySubscription,
  SubscriptionProductIDs.YearlySubscription,
];

/// 🔹 Helper to get title from productId
String getTitleFromProductId(String productId) {
  final productTitles = {
    SubscriptionProductIDs.Adfree: "Full Ads Free Version",
    SubscriptionProductIDs.Intersfree: "Full Screen Ads Free Version",
    SubscriptionProductIDs.WeeklySubscription: "Weekly Ads Free Pro Version",
    SubscriptionProductIDs.MonthlySubscription: "Monthly Ads Free Pro Version",
    SubscriptionProductIDs.YearlySubscription: "Yearly Ads Free Pro Version",
  };

  return productTitles[productId] ?? "Unknown Plan";
}

class SubscriptionProductIDs {
  // Define platform-specific constant values directly
  static const String iOS_WeeklySubscription = "";
  static const String Android_WeeklySubscription = "keyboardmouseeweekly";

  static const String iOS_MonthlySubscription = "";
  static const String Android_MonthlySubscription = "keyboardmousemonthly";

  static const String iOS_YearlySubscription = "";
  static const String Android_YearlySubscription = "keyboardmouseyearly";

  static const String iOS_Adfree = "";
  static const String Android_Adfree = "";

  static const String iOS_Intersfree = "";
  static const String Android_Intersfree = "";

  static String get Intersfree =>
      Platform.isIOS ? iOS_Intersfree : Android_Intersfree;

  static String get Adfree => Platform.isIOS ? iOS_Adfree : Android_Adfree;

  static String get WeeklySubscription =>
      Platform.isIOS ? iOS_WeeklySubscription : Android_WeeklySubscription;

  static String get MonthlySubscription =>
      Platform.isIOS ? iOS_MonthlySubscription : Android_MonthlySubscription;

  static String get YearlySubscription =>
      Platform.isIOS ? iOS_YearlySubscription : Android_YearlySubscription;
}

//=============================================================
