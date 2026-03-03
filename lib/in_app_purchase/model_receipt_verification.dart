import 'dart:convert';

ModelReceiptVerification modelReceiptVerificationFromJson(
  String str, {
  int? httpStatusCode,
  String? message,
}) {
  final jsonMap = json.decode(str);
  return ModelReceiptVerification.fromJson(
    jsonMap,
    httpStatusCode: httpStatusCode,
    message: message,
  );
}

String modelReceiptVerificationToJson(ModelReceiptVerification data) =>
    json.encode(data.toJson());

class ModelReceiptVerification {
  final String environment;
  final Receipt? receipt;
  final List<LatestReceiptInfo> latestReceiptInfo;
  final String? latestReceipt;
  final List<PendingRenewalInfo> pendingRenewalInfo;
  final int status;

  // 🔹 New fields
  final int httpStatusCode;
  final String message;

  ModelReceiptVerification({
    required this.environment,
    required this.receipt,
    required this.latestReceiptInfo,
    required this.pendingRenewalInfo,
    required this.status,
    this.latestReceipt,
    this.httpStatusCode = 0,
    this.message = "",
  });

  factory ModelReceiptVerification.fromJson(
    Map<String, dynamic> json, {
    int? httpStatusCode,
    String? message,
  }) => ModelReceiptVerification(
    environment: json["environment"] ?? "",
    receipt: json["receipt"] != null ? Receipt.fromJson(json["receipt"]) : null,
    latestReceiptInfo:
        (json["latest_receipt_info"] as List?)
            ?.map((x) => LatestReceiptInfo.fromJson(x))
            .toList() ??
        [],
    latestReceipt: json["latest_receipt"],
    pendingRenewalInfo:
        (json["pending_renewal_info"] as List?)
            ?.map((x) => PendingRenewalInfo.fromJson(x))
            .toList() ??
        [],
    status: json["status"] ?? 599,
    httpStatusCode: httpStatusCode ?? 0,
    message: message ?? "",
  );

  Map<String, dynamic> toJson() => {
    "environment": environment,
    "receipt": receipt?.toJson(),
    "latest_receipt_info": latestReceiptInfo.map((x) => x.toJson()).toList(),
    "latest_receipt": latestReceipt,
    "pending_renewal_info": pendingRenewalInfo.map((x) => x.toJson()).toList(),
    "status": status,
    "http_status_code": httpStatusCode,
    "message": message,
  };
}

class Receipt {
  final String receiptType;
  final int adamId;
  final int appItemId;
  final String bundleId;
  final String applicationVersion;
  final int downloadId;
  final int versionExternalIdentifier;
  final String receiptCreationDate;
  final String receiptCreationDateMs;
  final String receiptCreationDatePst;
  final String requestDate;
  final String requestDateMs;
  final String requestDatePst;
  final String originalPurchaseDate;
  final String originalPurchaseDateMs;
  final String originalPurchaseDatePst;
  final String originalApplicationVersion;
  final List<LatestReceiptInfo>? inApp; // 🔹 made nullable

  Receipt({
    required this.receiptType,
    required this.adamId,
    required this.appItemId,
    required this.bundleId,
    required this.applicationVersion,
    required this.downloadId,
    required this.versionExternalIdentifier,
    required this.receiptCreationDate,
    required this.receiptCreationDateMs,
    required this.receiptCreationDatePst,
    required this.requestDate,
    required this.requestDateMs,
    required this.requestDatePst,
    required this.originalPurchaseDate,
    required this.originalPurchaseDateMs,
    required this.originalPurchaseDatePst,
    required this.originalApplicationVersion,
    this.inApp,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    receiptType: json["receipt_type"] ?? "",
    adamId: json["adam_id"] ?? 0,
    appItemId: json["app_item_id"] ?? 0,
    bundleId: json["bundle_id"] ?? "",
    applicationVersion: json["application_version"] ?? "",
    downloadId: json["download_id"] ?? 0,
    versionExternalIdentifier: json["version_external_identifier"] ?? 0,
    receiptCreationDate: json["receipt_creation_date"] ?? "",
    receiptCreationDateMs: json["receipt_creation_date_ms"] ?? "",
    receiptCreationDatePst: json["receipt_creation_date_pst"] ?? "",
    requestDate: json["request_date"] ?? "",
    requestDateMs: json["request_date_ms"] ?? "",
    requestDatePst: json["request_date_pst"] ?? "",
    originalPurchaseDate: json["original_purchase_date"] ?? "",
    originalPurchaseDateMs: json["original_purchase_date_ms"] ?? "",
    originalPurchaseDatePst: json["original_purchase_date_pst"] ?? "",
    originalApplicationVersion: json["original_application_version"] ?? "",
    inApp:
        (json["in_app"] as List?)
            ?.map((x) => LatestReceiptInfo.fromJson(x))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "receipt_type": receiptType,
    "adam_id": adamId,
    "app_item_id": appItemId,
    "bundle_id": bundleId,
    "application_version": applicationVersion,
    "download_id": downloadId,
    "version_external_identifier": versionExternalIdentifier,
    "receipt_creation_date": receiptCreationDate,
    "receipt_creation_date_ms": receiptCreationDateMs,
    "receipt_creation_date_pst": receiptCreationDatePst,
    "request_date": requestDate,
    "request_date_ms": requestDateMs,
    "request_date_pst": requestDatePst,
    "original_purchase_date": originalPurchaseDate,
    "original_purchase_date_ms": originalPurchaseDateMs,
    "original_purchase_date_pst": originalPurchaseDatePst,
    "original_application_version": originalApplicationVersion,
    "in_app": inApp?.map((x) => x.toJson()).toList(),
  };
}

class LatestReceiptInfo {
  final String productId;
  final String transactionId;
  final String originalTransactionId;
  final String purchaseDate;
  final String purchaseDateMs;
  final String expiresDateMs;
  final String webOrderLineItemId;
  final String isTrialPeriod;
  final String isInIntroOfferPeriod;
  final String? inAppOwnershipType;
  final String? subscriptionGroupIdentifier;
  final String? cancellationDate;
  final String? cancellationReason;
  final String? gracePeriodExpiresDate;
  final String? priceConsentStatus;

  LatestReceiptInfo({
    required this.productId,
    required this.transactionId,
    required this.originalTransactionId,
    required this.purchaseDate,
    required this.purchaseDateMs,
    required this.expiresDateMs,
    required this.webOrderLineItemId,
    required this.isTrialPeriod,
    required this.isInIntroOfferPeriod,
    this.inAppOwnershipType,
    this.subscriptionGroupIdentifier,
    this.cancellationDate,
    this.cancellationReason,
    this.gracePeriodExpiresDate,
    this.priceConsentStatus,
  });

  factory LatestReceiptInfo.fromJson(Map<String, dynamic> json) =>
      LatestReceiptInfo(
        productId: json["product_id"] ?? "",
        transactionId: json["transaction_id"] ?? "",
        originalTransactionId: json["original_transaction_id"] ?? "",
        purchaseDate: json["purchase_date"] ?? "",
        purchaseDateMs: json["purchase_date_ms"] ?? "",
        expiresDateMs: json["expires_date_ms"] ?? "",
        webOrderLineItemId: json["web_order_line_item_id"] ?? "",
        isTrialPeriod: json["is_trial_period"] ?? "false",
        isInIntroOfferPeriod: json["is_in_intro_offer_period"] ?? "false",
        inAppOwnershipType: json["in_app_ownership_type"],
        subscriptionGroupIdentifier: json["subscription_group_identifier"],
        cancellationDate: json["cancellation_date"],
        cancellationReason: json["cancellation_reason"],
        gracePeriodExpiresDate: json["grace_period_expires_date"],
        priceConsentStatus: json["price_consent_status"],
      );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "transaction_id": transactionId,
    "original_transaction_id": originalTransactionId,
    "purchase_date": purchaseDate,
    "purchase_date_ms": purchaseDateMs,
    "expires_date_ms": expiresDateMs,
    "web_order_line_item_id": webOrderLineItemId,
    "is_trial_period": isTrialPeriod,
    "is_in_intro_offer_period": isInIntroOfferPeriod,
    "in_app_ownership_type": inAppOwnershipType,
    "subscription_group_identifier": subscriptionGroupIdentifier,
    "cancellation_date": cancellationDate,
    "cancellation_reason": cancellationReason,
    "grace_period_expires_date": gracePeriodExpiresDate,
    "price_consent_status": priceConsentStatus,
  };
}

class PendingRenewalInfo {
  final String autoRenewProductId;
  final String productId;
  final String originalTransactionId;
  final String autoRenewStatus;
  final String? expirationIntent;
  final String? isInBillingRetryPeriod;

  PendingRenewalInfo({
    required this.autoRenewProductId,
    required this.productId,
    required this.originalTransactionId,
    required this.autoRenewStatus,
    this.expirationIntent,
    this.isInBillingRetryPeriod,
  });

  factory PendingRenewalInfo.fromJson(Map<String, dynamic> json) =>
      PendingRenewalInfo(
        autoRenewProductId: json["auto_renew_product_id"] ?? "",
        productId: json["product_id"] ?? "",
        originalTransactionId: json["original_transaction_id"] ?? "",
        autoRenewStatus: json["auto_renew_status"] ?? "0",
        expirationIntent: json["expiration_intent"],
        isInBillingRetryPeriod: json["is_in_billing_retry_period"],
      );

  Map<String, dynamic> toJson() => {
    "auto_renew_product_id": autoRenewProductId,
    "product_id": productId,
    "original_transaction_id": originalTransactionId,
    "auto_renew_status": autoRenewStatus,
    "expiration_intent": expirationIntent,
    "is_in_billing_retry_period": isInBillingRetryPeriod,
  };
}
