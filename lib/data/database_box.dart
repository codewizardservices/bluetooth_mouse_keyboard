import 'dart:io';

import 'package:bluetoothairmousekeyboard/extra/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/general_values.dart';

const subscriptionStatus = "subscriptionStatus";
const purchaseDetailsSave = "purchaseDetailsSave";

class DatabaseBox {
  // Step 1

  //===================================
  /// ✅ Safe open
  static Future<Box<PurchaseDetailsSave>> getPurchaseDetailsBox() async {
    if (!Hive.isBoxOpen(purchaseDetailsSave)) {
      await Hive.openBox<PurchaseDetailsSave>(purchaseDetailsSave);
    }
    return Hive.box<PurchaseDetailsSave>(purchaseDetailsSave);
  }

  /// ✅ Save or update based on purchaseID / originalTransactionId
  static Future<void> saveOrUpdatePurchase(PurchaseDetailsSave purchase) async {
    AppLogger.info(
      "ScreenDeviceDiscovery",
      "box isOpen",
      "saveOrUpdatePurchase",
    );
    Box<PurchaseDetailsSave> box_setting = await getPurchaseDetailsBox();

    AppLogger.info("ScreenDeviceDiscovery", "box isOpen", box_setting.isOpen);
    AppLogger.info("ScreenDeviceDiscovery", "box length", box_setting.length);
    final existingKey = box_setting.keys.firstWhere((key) {
      final existing = box_setting.get(key);
      return existing?.purchaseID == purchase.purchaseID ||
          (existing?.originalTransactionId.isNotEmpty == true &&
              existing?.originalTransactionId ==
                  purchase.originalTransactionId);
    }, orElse: () => null);

    if (existingKey != null) {
      await box_setting.put(existingKey, purchase);
      AppLogger.info("DB", "Updated existing purchase ${purchase.productID}");
    } else {
      await box_setting.add(purchase);
      AppLogger.info("DB", "Added new purchase ${purchase.productID}");
    }
  }

  /// ✅ Get latest active plan (handles renewal upgrades/downgrades)
  static Future<PurchaseDetailsSave?> getActivePlanWithRenewal() async {
    final box = await getPurchaseDetailsBox();
    if (box.isEmpty) return null;

    final allPurchases = box.values.toList();

    final activePurchases = allPurchases.where((p) {
      AppLogger.info(
        "getPurchaseDetailsBox",
        "p.subscriptionStatus.name",
        p.subscriptionStatus.name,
      );
      AppLogger.info("getPurchaseDetailsBox", "p.expireDate", p.expireDate);
      AppLogger.info(
        "getPurchaseDetailsBox",
        "Campare",
        (p.status && (p.expireDate?.isAfter(DateTime.now()) ?? false)),
      );
      return !(p.subscriptionStatus.name == SubscriptionStatus.expired.name) ||
          (p.status && (p.expireDate?.isAfter(DateTime.now()) ?? false));
    });

    if (activePurchases.isEmpty) return null;

    // Sort by expireDate (latest first)
    final sorted = activePurchases.toList()
      ..sort(
        (a, b) => (a.expireDate ?? DateTime(1970)).compareTo(
          b.expireDate ?? DateTime(1970),
        ),
      );

    final latest = sorted.last;

    if (latest.autoRenewProductId.isNotEmpty &&
        latest.autoRenewProductId != latest.productID) {
      AppLogger.info(
        "DB",
        "Plan will auto-renew/upgrade: ${latest.productID} ➝ ${latest.autoRenewProductId}",
      );
    }

    return latest;
  }

  /// ✅ All purchases
  static List<PurchaseDetailsSave> getPurchaseDetailsSaveList() {
    if (!Hive.isBoxOpen(purchaseDetailsSave)) return [];
    final box = Hive.box<PurchaseDetailsSave>(purchaseDetailsSave);
    return box.values.toList().cast<PurchaseDetailsSave>();
  }

  /// ✅ Save one purchase (keyed by productID)
  static Future<void> savePurchase(PurchaseDetailsSave purchase) async {
    final box = await getPurchaseDetailsBox();
    await box.put(purchase.productID, purchase);
  }

  /// ✅ Save multiple
  static Future<void> savePurchaseList(List<PurchaseDetailsSave> list) async {
    final box = await getPurchaseDetailsBox();
    for (var element in list) {
      await box.put(element.productID, element);
    }
  }

  /// ✅ Delete one
  static Future<void> deletePurchase(String productID) async {
    final box = await getPurchaseDetailsBox();
    await box.delete(productID);
  }

  /// ✅ Clear all (for logout)
  static Future<void> clearAllPurchases() async {
    final box = await getPurchaseDetailsBox();
    await box.clear();
  }

  static Future<bool> isPremiumActive() async {
    try {
      final box = await getPurchaseDetailsBox();
      if (box.isEmpty) return false;

      final now = DateTime.now();

      // Any purchase with status true is treated as active for Android.
      final activePurchases = box.values.where((p) {
        if (p.platform == Platform.isAndroid) {
          return p.status && p.subscriptionStatus == SubscriptionStatus.active;
        }
        // For iOS, check expiry
        return p.status && (p.expireDate?.isAfter(now) ?? false);
      });

      final hasPremium = activePurchases.isNotEmpty;
      AppLogger.info("DatabaseBox", "isPremiumActive", "Result: $hasPremium");

      return hasPremium;
    } catch (e) {
      AppLogger.error("DatabaseBox", "isPremiumActive", e.toString());
      return false;
    }
  }

  /// ✅ Determine subscription status
  static Future<SubscriptionStatus> getSubscriptionStatus() async {
    final list = getPurchaseDetailsSaveList();

    final activePurchases = list.where(
      (p) => p.status && (p.expireDate?.isAfter(DateTime.now()) ?? false),
    );

    if (activePurchases.isEmpty) {
      return SubscriptionStatus.noSubscription;
    }

    // Sort by expire date
    final sorted = activePurchases.toList()
      ..sort(
        (a, b) => (a.expireDate ?? DateTime(1970)).compareTo(
          b.expireDate ?? DateTime(1970),
        ),
      );

    final latest = sorted.last;

    switch (latest.productID) {
      case SubscriptionProductIDs.iOS_Intersfree:
      case SubscriptionProductIDs.Android_Intersfree:
        return SubscriptionStatus.interstitialFree;

      case SubscriptionProductIDs.iOS_Adfree:
      case SubscriptionProductIDs.Android_Adfree:
      case SubscriptionProductIDs.iOS_WeeklySubscription:
      case SubscriptionProductIDs.Android_WeeklySubscription:
      case SubscriptionProductIDs.iOS_MonthlySubscription:
      case SubscriptionProductIDs.Android_MonthlySubscription:
      case SubscriptionProductIDs.iOS_YearlySubscription:
      case SubscriptionProductIDs.Android_YearlySubscription:
        return SubscriptionStatus.adsFree;

      default:
        return SubscriptionStatus.noSubscription;
    }
  }

  // Step 3
  static getHiveFunction() async {
    try {
      await Hive.initFlutter();

      // Register adapters first
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SubscriptionStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PurchaseDetailsSaveAdapter());
      }

     

      if (!Hive.isBoxOpen(purchaseDetailsSave)) {
        await Hive.openBox<PurchaseDetailsSave>(purchaseDetailsSave);
      }
      if (!Hive.isBoxOpen(subscriptionStatus)) {
        await Hive.openBox<SubscriptionStatus>(subscriptionStatus);
      }

    

      // AppLogger.info("Hive", "All boxes initialized");
    } catch (e, st) {
      AppLogger.error("GiveHiveFunction", "init issue", e.toString());
      print(st);
    }
  }

  static String getNewKey() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
