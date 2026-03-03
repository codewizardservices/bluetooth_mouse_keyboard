// lib/in_app_purchase/in_app_purchase_provider.dart
import 'dart:async';
import 'dart:io';


import 'package:bluetoothairmousekeyboard/extra/widgets_reusing.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:bluetoothairmousekeyboard/admob/ad_state_provider.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';
import 'package:bluetoothairmousekeyboard/extra/app_logger.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/constant_inapps.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/general_values.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/service_receipt_verifier.dart';
import 'package:provider/provider.dart';


// Helper Extension
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class InAppPurchaseProvider with ChangeNotifier {
  // --- PRIVATE STATE ---
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _purchaseStreamSubscription;
  List<SubscriptionPlan> _availableSubscriptionPlans = [];
  bool _isAvailable = false;
  bool _loadingProducts = true;
  String? _queryProductError;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  bool _isPremiumUser = false;
  String? _activePremiumProductId;
  String? _nextRenewalProductId;
  String _selectedProductId = '';

  BuildContext? _context;
  bool _isInitialized = false;

  // --- PUBLIC GETTERS (for the UI to listen to) ---
  List<SubscriptionPlan> get availablePlans => _availableSubscriptionPlans;
  bool get isLoadingProducts => _loadingProducts;
  bool get isPurchasing => _isPurchasing;
  bool get isRestoring => _isRestoring;
  bool get isPremiumUser => _isPremiumUser;
  String? get activePremiumProductId => _activePremiumProductId;
  String? get nextRenewalProductId => _nextRenewalProductId;
  String get selectedProductId => _selectedProductId;
  String? get queryProductError => _queryProductError;

  InAppPurchaseProvider();

  void setIsPurchasing(bool value) {
    _isPurchasing = value;
    notifyListeners();
  }

  // --- PUBLIC METHODS (for the UI to call) ---
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    _context = context;
    _isInitialized = true;
    await _initializeIAP();
  }

  void selectPlan(String productId) {
    if (_isPremiumUser && productId == _activePremiumProductId) return;
    _selectedProductId = productId;
    notifyListeners();
  }

  void buyProduct() {
    if (_isPurchasing || _selectedProductId.isEmpty) return;
    final selectedPlan = _availableSubscriptionPlans.firstWhereOrNull(
      (p) => p.id == _selectedProductId,
    );
    if (selectedPlan?.productDetails == null) return;
    _isPurchasing = true;
    notifyListeners();
    final purchaseParam = PurchaseParam(
      productDetails: selectedPlan!.productDetails!,
    );
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (_isRestoring) return;
    _isRestoring = true;
    notifyListeners();
    try {
      await _inAppPurchase.restorePurchases();
    } catch (_) {
      // Handle error if needed
    } finally {
      if (_context != null && _context!.mounted) {
        _isRestoring = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshStatus() async {
    if (!_isInitialized || _context == null) return;
    await ReceiptVerifierService.verifyAndSavePurchase(_context!);
    await _checkPremiumStatus();
  }

  // --- PRIVATE LOGIC METHODS ---
  Future<void> _initializeIAP() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      _loadingProducts = false;
      _queryProductError = 'In-app purchases not available on this device.';
      notifyListeners();
      return;
    }

    _purchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdates(purchaseDetailsList);
      },
      onDone: () => _purchaseStreamSubscription.cancel(),
      onError: (error) {
        _queryProductError = 'Error occurred: ${error.toString()}';
        _isPurchasing = false;
        notifyListeners();
      },
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _inAppPurchase.queryProductDetails(
      productids.toSet(),
    );
    if (response.error != null) {
      _queryProductError = response.error!.message;
      _loadingProducts = false;
      notifyListeners();
      return;
    }

    _availableSubscriptionPlans =
        response.productDetails
            .map((details) => SubscriptionPlan.fromProductDetails(details))
            .toList()
          ..sort(
            (a, b) => a.productDetails!.rawPrice.compareTo(
              b.productDetails!.rawPrice,
            ),
          );

    if (_selectedProductId.isEmpty && _availableSubscriptionPlans.isNotEmpty) {
      _selectedProductId = _availableSubscriptionPlans.first.id;
    }
    _loadingProducts = false;
    notifyListeners();
    await _checkPremiumStatus();
  }

  void _listenToPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    if (_context == null) return;
    for (final details in purchaseDetailsList) {
      AppLogger.debug("_deliverPurchase", "details.status", details.status);
      AppLogger.debug(
        "_deliverPurchase",
        "details.productID",
        details.productID,
      );
      if (details.status == PurchaseStatus.pending) {
        _isPurchasing = true;
        Provider.of<AdStateProvider>(
          _context!,
          listen: false,
        ).checkSubscriptionStatus();
        WidgetsReusing.getMaterialBar(_context!, 'Purchase pending...');
      } else {
        _isPurchasing = false;
        _isRestoring = false;
        if (details.status == PurchaseStatus.error) {
          setIsPurchasing(false);
          WidgetsReusing.getMaterialBar(
            _context!,
            'Purchase failed: ${details.error?.message}',
          );
        } else if (details.status == PurchaseStatus.purchased ||
            details.status == PurchaseStatus.restored) {
          _deliverPurchase(details);
        } else if (details.status == PurchaseStatus.canceled) {
          setIsPurchasing(false);
          WidgetsReusing.getMaterialBar(_context!, 'Purchase canceled.');
        }
        Provider.of<AdStateProvider>(
          _context!,
          listen: false,
        ).checkSubscriptionStatus();
      }
    }
  }

  Future<void> _deliverPurchase(PurchaseDetails purchaseDetails) async {
    if (_context == null) return;
    AppLogger.debug(
      "_deliverPurchase",
      "pendingCompletePurchase",
      purchaseDetails.pendingCompletePurchase,
    );
    AppLogger.success(
      "InappOurchaseProvider",
      "purchaseDetails",
      purchaseDetails.toString(),
    );
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
    if (Platform.isIOS) {
      final bool verified = await ReceiptVerifierService.verifyAndSavePurchase(
        _context!,
        purchaseDetails.verificationData.serverVerificationData,
      );

      if (verified) {
        await showDialog(
          context: _context!,
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Purchase Successful!"),
                content: const Text("Thank you for subscribing to Premium."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("GET STARTED"),
                  ),
                ],
              ),
        );
        await _checkPremiumStatus();
      } else {
        await showDialog(
          context: _context!,
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Purchase Failed!"),
                content: const Text("No pending purchase found."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } else if (Platform.isAndroid) {
      // Convert the PurchaseDetails into your Hive model

      final purchase = PurchaseDetailsSave(
        purchaseID: purchaseDetails.purchaseID,
        productID: purchaseDetails.productID,
        verificationData:
            purchaseDetails.verificationData.serverVerificationData,
        transactionDate:
            DateTime.tryParse(purchaseDetails.transactionDate ?? '') ??
            DateTime.now(),
        platform: "android",
        subscriptionStatus: SubscriptionStatus.active,
        status: true, // since it was delivered
        expireDate: DateTime.now().add(const Duration(days: 30)),
      );

      // Save or update into Hive
      await DatabaseBox.saveOrUpdatePurchase(purchase);

      // Update premium status
      await _checkPremiumStatus();

      // UI feedback
      await showDialog(
        context: _context!,
        barrierDismissible: false,
        builder:
            (ctx) => AlertDialog(
              title: const Text("Purchase Restored!"),
              content: const Text("Your Premium access is now active."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _checkPremiumStatus() async {
    final savedPurchases = await DatabaseBox.getPurchaseDetailsSaveList();
    final activePurchase = savedPurchases.firstWhereOrNull(
      (p) => p.isCurrentlyActive,
    );

    _isPremiumUser = activePurchase != null;
    _activePremiumProductId = activePurchase?.productID;
    _nextRenewalProductId = null;

    if (activePurchase != null && activePurchase.willAutoRenew) {
      if (activePurchase.autoRenewProductId.isNotEmpty &&
          activePurchase.autoRenewProductId != activePurchase.productID) {
        _nextRenewalProductId = activePurchase.autoRenewProductId;
      }
    }

    if (!_isPremiumUser && _availableSubscriptionPlans.isNotEmpty) {
      _selectedProductId = _availableSubscriptionPlans.first.id;
    } else if (_isPremiumUser) {
      _selectedProductId = _activePremiumProductId ?? '';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseStreamSubscription.cancel();
    super.dispose();
  }
}
