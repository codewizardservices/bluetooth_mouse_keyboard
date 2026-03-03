import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:bluetoothairmousekeyboard/admob/ad_state_provider.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';
import 'package:bluetoothairmousekeyboard/extra/app_logger.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/general_values.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/model_receipt_verification.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/service_invoices.dart';
import 'package:provider/provider.dart';

class ReceiptVerifierService {
  /// Main method to call for verification
  static Future<bool> verifyAndSavePurchase(
    BuildContext context, [
    String? overrideReceipt,
  ]) async {
    final receiptData =
        overrideReceipt ?? await IosReceiptHelper.getIosReceipt();

    if (receiptData == null || receiptData.isEmpty) {
      AppLogger.error("INAPPPurchase", "No receipt data found.");
      return false;
    }

    final receiptBody = {
      'receipt-data': receiptData,
      'exclude-old-transactions': true,
      'password': iosSharedSecret,
    };

    try {
      final responseModel = await _validateWithApple(receiptBody);

      if (responseModel == null || responseModel.status != 0) {
        AppLogger.error(
          "INAPPPurchase",
          "Verification failed, status: ${responseModel?.status}",
        );
        // final box = await DatabaseBox.getPurchaseDetailsBox();
        // await box.clear();
        return false;
      }

      // Transactions
      final transactions =
          responseModel.latestReceiptInfo.isNotEmpty
              ? responseModel.latestReceiptInfo
              : responseModel.receipt?.inApp ?? [];

      AppLogger.info(
        "INAPPPurchase",
        "No transactions transactions ${transactions.length}.",
      );

      if (transactions.isEmpty) {
        AppLogger.info("INAPPPurchase", "No transactions found in receipt.");
        await DatabaseBox.clearAllPurchases();

        var ssss = DatabaseBox.getPurchaseDetailsSaveList();
        AppLogger.info(
          "INAPPPurchase",
          "No transactions found in receipt ${ssss.length}.",
        );

        return false;
      }

      // Most recent transaction
      LatestReceiptInfo? latestTransaction;
      for (var transaction in transactions) {
        try {
          if (latestTransaction == null ||
              int.parse(transaction.purchaseDateMs) >
                  int.parse(latestTransaction.purchaseDateMs)) {
            latestTransaction = transaction;
          }
        } catch (_) {}
      }

      if (latestTransaction != null) {
        // Dates
        final expireDate = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(latestTransaction.expiresDateMs) ?? 0,
          isUtc: true,
        );
        final purchaseDate = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(latestTransaction.purchaseDateMs) ?? 0,
          isUtc: true,
        );
        final cancellationDate =
            (latestTransaction.cancellationDate != null)
                ? DateTime.fromMillisecondsSinceEpoch(
                  int.tryParse(latestTransaction.cancellationDate!) ?? 0,
                  isUtc: true,
                )
                : null;

        // Subscription status
        SubscriptionStatus status = SubscriptionStatus.active;

        // Use Apple's server time instead of device time
        final serverNow = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(responseModel.receipt?.requestDateMs ?? '0') ?? 0,
          isUtc: true,
        );

        if (expireDate.isBefore(serverNow)) {
          status = SubscriptionStatus.expired;
        } else if (cancellationDate != null) {
          status = SubscriptionStatus.cancelled;
        }

        // Auto-renew info (from pending_renewal_info)
        String autoRenewProductId = "";
        bool autoRenewStatus = false;
        DateTime? nextRenewalDate;

        if (responseModel.pendingRenewalInfo.isNotEmpty) {
          final renewalInfo = responseModel.pendingRenewalInfo.firstWhere(
            (info) => info.productId == latestTransaction!.productId,
            orElse: () => responseModel.pendingRenewalInfo.first,
          );

          autoRenewProductId = renewalInfo.autoRenewProductId ?? "";
          autoRenewStatus = renewalInfo.autoRenewStatus == "1";

          if (autoRenewStatus) {
            nextRenewalDate = expireDate; // usually same as expireDate
          }
        }

        // Save purchase details
        final purchaseDetail = PurchaseDetailsSave(
          purchaseID: latestTransaction.transactionId,
          productID: latestTransaction.productId,
          verificationData: receiptData,
          transactionDate: purchaseDate,
          expireDate: expireDate,

          status: status == SubscriptionStatus.active,
          originalTransactionId: latestTransaction.originalTransactionId ?? "",
          webOrderLineItemId: latestTransaction.webOrderLineItemId ?? "",
          // price: latestTransaction.price ?? "",
          // currency: latestTransaction.currency ?? "",
          // localizedPrice: latestTransaction.localizedPrice ?? "",
          isTrial: latestTransaction.isTrialPeriod == "true",
          isInIntroOffer: latestTransaction.isInIntroOfferPeriod == "true",
          inAppOwnershipType: "", // not available in Apple response
          subscriptionGroupIdentifier:
              latestTransaction.subscriptionGroupIdentifier ?? "",
          autoRenewProductId: autoRenewProductId,
          autoRenewStatus: autoRenewStatus,
          nextRenewalDate: nextRenewalDate,
          cancellationDate: cancellationDate,
          receiptEnvironment: responseModel.environment ?? "",
          httpStatusCode: responseModel.httpStatusCode,
          receiptMessage: responseModel.message ?? "",
          platform: Platform.isIOS ? "iOS" : "Android",
          subscriptionStatus: status,
        );

        AppLogger.success(
          "purchaseDetail",
          "purchaseDetail",
          purchaseDetail.toMap(),
        );

        await DatabaseBox.saveOrUpdatePurchase(purchaseDetail);
        Provider.of<AdStateProvider>(
          context,
          listen: false,
        ).checkSubscriptionStatus();
        return true;
      } else {
        AppLogger.error("INAPPPurchase", "No valid subscriptions found.");
        // final box = await DatabaseBox.getPurchaseDetailsBox();
        // await box.clear();
        return false;
      }
    } catch (e) {
      AppLogger.error("INAPPPurchase", "Verification error: $e");
      return false;
    }
  }

  /// Handles Prod → Sandbox retry
  static Future<ModelReceiptVerification?> _validateWithApple(
    Map<String, dynamic> receiptBody, {
    bool isRetry = false,
  }) async {
    final response = await ServicesInAppPurchase.validateReceiptIos(
      receiptBody,
      useSandbox: isRetry,
    );

    AppLogger.success("ReceiptVerifier", "response", response.statusCode);
    // AppLogger.success("ReceiptVerifier", "response body", response.body);

    String message = "Unknown error";
    final responseModel = modelReceiptVerificationFromJson(
      response.body,
      httpStatusCode: response.statusCode,
    );

    AppLogger.success(
      "ReceiptVerifier",
      "response responseModel",
      responseModel.toJson(),
    );

    switch (responseModel.status) {
      case 0:
        message = "Success";
        break;
      case 21007:
        message = "Sandbox receipt sent to Production";
        if (!isRetry) {
          AppLogger.info("INAPPPurchase", "Retrying with Sandbox...");
          return _validateWithApple(receiptBody, isRetry: true);
        }
        break;
      case 21000:
        message = "Malformed receipt or JSON.";
        break;
      case 21002:
        message = "Bad receipt data.";
        break;
      case 21003:
        message = "Receipt authentication failed.";
        break;
      case 21004:
        message = "Shared secret mismatch.";
        break;
      case 21005:
        message = "Apple server unavailable.";
        break;
      case 21006:
        message = "Subscription expired.";
        break;
      case 21010:
        message = "Receipt invalid.";
        break;
      default:
        message = "Unknown status: ${responseModel.status}";
        break;
    }

    return ModelReceiptVerification.fromJson(
      json.decode(response.body),
      httpStatusCode: response.statusCode,
      message: message,
    );
  }
}

const _channel = MethodChannel("$bundleId/receipt");

class IosReceiptHelper {
  static Future<String?> getIosReceipt() async {
    try {
      final receipt = await _channel.invokeMethod<String>('getReceipt');
      return receipt;
    } catch (e) {
      AppLogger.error("INAPPPurchase", "Error fetching iOS receipt: $e");
      return null;
    }
  }
}
