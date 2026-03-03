import 'package:hive_flutter/hive_flutter.dart';

part 'databases.g.dart';

/// Enum for subscription state
@HiveType(typeId: 0)
enum SubscriptionStatus {
  @HiveField(0)
  active, // currently valid

  @HiveField(1)
  expired, // expired (end date < now)

  @HiveField(2)
  pending, // waiting to start (plan upgrade/downgrade)

  @HiveField(3)
  cancelled, // user cancelled (will not renew)

  @HiveField(4)
  paused, // Google Play: paused subscription

  @HiveField(5)
  noSubscription,

  @HiveField(6)
  interstitialFree,

  @HiveField(7)
  adsFree,
}

/// Core model for managing subscription lifecycle
@HiveType(typeId: 1)
class PurchaseDetailsSave extends HiveObject {
  // Core purchase identifiers
  @HiveField(1)
  dynamic purchaseID;

  @HiveField(2, defaultValue: "")
  String productID;

  // Verification / receipt
  @HiveField(3, defaultValue: "")
  String verificationData;

  @HiveField(4)
  DateTime transactionDate;

  @HiveField(5)
  DateTime? expireDate;

  // Legacy status (still useful in DB)
  @HiveField(6, defaultValue: false)
  bool status;

  @HiveField(7, defaultValue: "")
  String originalTransactionId;

  @HiveField(8, defaultValue: "")
  String webOrderLineItemId;

  // Pricing
  @HiveField(9, defaultValue: "")
  String price;

  @HiveField(10, defaultValue: "")
  String currency;

  @HiveField(11, defaultValue: "")
  String localizedPrice; // e.g. "$9.99 / month"

  // Trial / Offers
  @HiveField(12, defaultValue: false)
  bool isTrial;

  @HiveField(13, defaultValue: false)
  bool isInIntroOffer;

  // Ownership / Grouping
  @HiveField(14, defaultValue: "")
  String inAppOwnershipType;

  @HiveField(15, defaultValue: "")
  String subscriptionGroupIdentifier;

  // Auto-renewal
  @HiveField(16, defaultValue: "")
  String autoRenewProductId; // ✅ replaces old renewalProductId

  @HiveField(17, defaultValue: false)
  bool autoRenewStatus;

  @HiveField(18)
  DateTime? nextRenewalDate;

  @HiveField(19)
  DateTime? cancellationDate;

  // Extra metadata
  @HiveField(20, defaultValue: "")
  String receiptEnvironment;

  @HiveField(21, defaultValue: 0)
  int httpStatusCode;

  @HiveField(22, defaultValue: "")
  String receiptMessage;

  @HiveField(23, defaultValue: "")
  String platform; // "ios" / "android"

  /// Centralized subscription state
  @HiveField(24)
  SubscriptionStatus subscriptionStatus;

  PurchaseDetailsSave({
    this.purchaseID,
    this.productID = "",
    this.verificationData = "",
    DateTime? transactionDate,
    this.expireDate,
    this.status = false,
    this.originalTransactionId = "",
    this.webOrderLineItemId = "",
    this.price = "",
    this.currency = "",
    this.localizedPrice = "",
    this.isTrial = false,
    this.isInIntroOffer = false,
    this.inAppOwnershipType = "",
    this.subscriptionGroupIdentifier = "",
    this.autoRenewProductId = "",
    this.autoRenewStatus = false,
    this.nextRenewalDate,
    this.cancellationDate,
    this.receiptEnvironment = "",
    this.httpStatusCode = 0,
    this.receiptMessage = "",
    this.platform = "",
    this.subscriptionStatus = SubscriptionStatus.active,
  }) : transactionDate = transactionDate ?? DateTime.now();

  /// --- Computed Helpers ---

  /// Expired if `expireDate` < now
  bool get isExpired =>
      expireDate != null && expireDate!.isBefore(DateTime.now());

  /// Currently valid plan (active + not expired)
  bool get isCurrentlyActive =>
      subscriptionStatus == SubscriptionStatus.active && !isExpired;

  /// Returns true if this plan will auto-renew
  bool get willAutoRenew => autoRenewStatus && !isExpired;

  /// Returns human-readable renewal label
  String get autoRenewLabel {
    if (subscriptionStatus == SubscriptionStatus.cancelled) {
      return "Cancelled";
    }
    if (subscriptionStatus == SubscriptionStatus.pending) {
      return "Pending Plan Change";
    }
    if (subscriptionStatus == SubscriptionStatus.expired) {
      return "Expired";
    }
    if (autoRenewStatus && nextRenewalDate != null) {
      return "Renews on ${nextRenewalDate!.toLocal()}";
    }
    if (autoRenewStatus) {
      return "Auto-renew ON";
    }
    return "Auto-renew OFF";
  }

  /// Returns the plan type in simple words
  String get planType {
    if (isTrial) return "Trial";
    if (isInIntroOffer) return "Intro Offer";
    return "Standard";
  }
}

extension PurchaseDetailsSaveMapper on PurchaseDetailsSave {
  Map<String, dynamic> toMap() {
    return {
      "purchaseID": purchaseID,
      "productID": productID,
      // "verificationData": verificationData.padLeft(10),
      "transactionDate": transactionDate.toIso8601String(),
      "expireDate": expireDate?.toIso8601String(),
      "status": status,
      "originalTransactionId": originalTransactionId,
      "webOrderLineItemId": webOrderLineItemId,
      "price": price,
      "currency": currency,
      "localizedPrice": localizedPrice,
      "isTrial": isTrial,
      "isInIntroOffer": isInIntroOffer,
      "inAppOwnershipType": inAppOwnershipType,
      "subscriptionGroupIdentifier": subscriptionGroupIdentifier,
      "autoRenewProductId": autoRenewProductId,
      "autoRenewStatus": autoRenewStatus,
      "nextRenewalDate": nextRenewalDate?.toIso8601String(),
      "cancellationDate": cancellationDate?.toIso8601String(),
      "receiptEnvironment": receiptEnvironment,
      "httpStatusCode": httpStatusCode,
      "receiptMessage": receiptMessage,
      "platform": platform,
      "subscriptionStatus": subscriptionStatus.name, // store enum as string
    };
  }

  /// Optional: reverse mapper if you need it
  static PurchaseDetailsSave fromMap(Map<String, dynamic> map) {
    return PurchaseDetailsSave(
      purchaseID: map["purchaseID"],
      productID: map["productID"] ?? "",
      verificationData: map["verificationData"] ?? "",
      transactionDate:
          DateTime.tryParse(map["transactionDate"] ?? "") ?? DateTime.now(),
      expireDate: map["expireDate"] != null
          ? DateTime.tryParse(map["expireDate"])
          : null,
      status: map["status"] ?? false,
      originalTransactionId: map["originalTransactionId"] ?? "",
      webOrderLineItemId: map["webOrderLineItemId"] ?? "",
      price: map["price"] ?? "",
      currency: map["currency"] ?? "",
      localizedPrice: map["localizedPrice"] ?? "",
      isTrial: map["isTrial"] ?? false,
      isInIntroOffer: map["isInIntroOffer"] ?? false,
      inAppOwnershipType: map["inAppOwnershipType"] ?? "",
      subscriptionGroupIdentifier: map["subscriptionGroupIdentifier"] ?? "",
      autoRenewProductId: map["autoRenewProductId"] ?? "",
      autoRenewStatus: map["autoRenewStatus"] ?? false,
      nextRenewalDate: map["nextRenewalDate"] != null
          ? DateTime.tryParse(map["nextRenewalDate"])
          : null,
      cancellationDate: map["cancellationDate"] != null
          ? DateTime.tryParse(map["cancellationDate"])
          : null,
      receiptEnvironment: map["receiptEnvironment"] ?? "",
      httpStatusCode: map["httpStatusCode"] ?? 0,
      receiptMessage: map["receiptMessage"] ?? "",
      platform: map["platform"] ?? "",
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.name == map["subscriptionStatus"],
        orElse: () => SubscriptionStatus.noSubscription,
      ),
    );
  }
}
