import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/entities/vip_config_entity.dart';

class IAPService {
  /// Service class to manage in-app purchases (IAP) using the `in_app_purchase` package.
  ///
  /// This class is implemented as a singleton to provide a single point of access
  /// for IAP functionality throughout the app.
  ///
  /// It supports loading available products, initiating purchases, restoring purchases,
  /// and handling purchase updates with appropriate callbacks for different purchase states.
  ///
  /// Supported platforms: iOS, macOS, Android.
  ///
  /// Usage:
  /// ```dart
  /// final iapService = IAPService();
  /// await iapService.initialize();
  /// iapService.onPurchaseSuccess = (purchase) { ... };
  /// iapService.purchaseProduct(productId);
  /// ```
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs from your MD file
  static const Set<String> _productIds = {
    'com.shenghua.note.vip_3001', // VIP 1
    'com.shenghua.note.vip3002', // VIP 2
    'com.shenghua.note.vip_3003', // VIP 3
  };

  // Available products
  List<ProductDetails> availableProducts = [];
  
  // Purchase status callbacks
  Function(PurchaseDetails)? onPurchaseSuccess;
  Function(PurchaseDetails, String)? onPurchaseError;
  Function(PurchaseDetails)? onPurchasePending;
  Function(PurchaseDetails)? onPurchaseRestored;

  // Optional error callback for external error handling
  Function(String, dynamic)? onError;

  void _logError(String message, [dynamic error]) {
    final errorMsg = error != null ? '$message: $error' : message;
    print('IAPService ERROR: $errorMsg');
    if (onError != null) {
      onError!(message, error);
    }
  }

  /// Initializes the IAP service.
  ///
  /// Checks platform support, availability of in-app purchases,
  /// sets up purchase update listener, and loads available products.
  ///
  /// Returns `true` if initialization succeeds, `false` otherwise.
  Future<bool> initialize() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS && !Platform.isAndroid) {
        throw UnsupportedError('Only iOS, macOS, and Android are supported');
      }

      final bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        _logError('In-app purchase is not available on this device');
        return false;
      }

      // Listen to purchase updates
      _subscription?.cancel(); // Cancel existing subscription if any
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {},
        onError: (error) {
          _logError('Purchase stream error', error);
        },
      );

      // Load available products
      await loadProducts();

      return true;
    } catch (e) {
      _logError('IAP initialization error', e);
      return false;
    }
  }

  /// Loads product details for the predefined product IDs.
  ///
  /// Updates the `availableProducts` list with the loaded products.
  /// Logs errors if product loading fails.
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        throw Exception('Failed to load products: ${response.error}');
      }

      availableProducts = response.productDetails;
      print('Loaded ${availableProducts.length} products');
      print('Available product IDs: ${availableProducts.map((p) => p.id).toList()}');
    } catch (e) {
      _logError('Error loading products', e);
    }
  }

  /// Initiates a purchase for the product with the given [productId].
  ///
  /// Returns `true` if the purchase flow started successfully, `false` otherwise.
  /// Throws an error if the product is not found or IAP is unavailable.
  Future<bool> purchaseProduct(String productId) async {
    try {
      // Ensure IAP is available
      if (!await _inAppPurchase.isAvailable()) {
        throw Exception('In-app purchases are not available');
      }

      // If no products loaded, try to load them first
      if (availableProducts.isEmpty) {
        print('No products loaded, attempting to load products...');
        await loadProducts();
      }

      final ProductDetails? productDetails = availableProducts
          .where((product) => product.id == productId)
          .firstOrNull;

      if (productDetails == null) {
        _logError('Product not found: $productId. Available products: ${availableProducts.map((p) => p.id).toList()}');
        throw Exception('Product not found: $productId. Available products: ${availableProducts.map((p) => p.id).toList()}');
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      _logError('Purchase error', e);
      return false;
    }
  }

  /// Restores previous purchases.
  ///
  /// Calls the underlying platform's restore purchases method.
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _logError('Restore purchases error', e);
    }
  }

  /// Completes the purchase process for the given [purchaseDetails].
  ///
  /// This should be called after processing the purchase to finalize it.
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      _logError('Complete purchase error', e);
    }
  }

  /// Internal handler for purchase updates received from the purchase stream.
  ///
  /// Dispatches to specific handlers based on the purchase status.
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _handleRestoredPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handleFailedPurchase(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchaseDetails);
          break;
      }
    }
  }

  /// Handles a purchase with status `pending`.
  ///
  /// Calls the `onPurchasePending` callback if set.
  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase pending: ${purchaseDetails.productID}');
    onPurchasePending?.call(purchaseDetails);
  }

  /// Handles a purchase with status `purchased`.
  ///
  /// Calls the `onPurchaseSuccess` callback and completes the purchase.
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase successful: ${purchaseDetails.productID}');
    onPurchaseSuccess?.call(purchaseDetails);
    completePurchase(purchaseDetails);
  }

  /// Handles a purchase with status `restored`.
  ///
  /// Calls the `onPurchaseRestored` callback and completes the purchase.
  void _handleRestoredPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase restored: ${purchaseDetails.productID}');
    onPurchaseRestored?.call(purchaseDetails);
    completePurchase(purchaseDetails);
  }

  /// Handles a purchase with status `error`.
  ///
  /// Calls the `onPurchaseError` callback with the error message and completes the purchase.
  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    final String error = purchaseDetails.error?.message ?? 'Unknown error';
    print('Purchase failed: ${purchaseDetails.productID}, Error: $error');
    onPurchaseError?.call(purchaseDetails, error);
    completePurchase(purchaseDetails);
  }

  /// Handles a purchase with status `canceled`.
  ///
  /// Calls the `onPurchaseError` callback with a cancellation message and completes the purchase.
  void _handleCanceledPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase canceled: ${purchaseDetails.productID}');
    onPurchaseError?.call(purchaseDetails, 'Purchase canceled by user');
    completePurchase(purchaseDetails);
  }

  /// Returns the [ProductDetails] for the given [productId], or `null` if not found.
  ProductDetails? getProductById(String productId) {
    return availableProducts
        .where((product) => product.id == productId)
        .firstOrNull;
  }

  /// Returns the [VipLevel] enum corresponding to the given [productId], or `null` if unknown.
  VipLevel? getVipLevelByProductId(String productId) {
    switch (productId) {
      case 'com.shenghua.note.vip_3001':
        return VipLevel.vipLevel1;
      case 'com.shenghua.note.vip_3002':
        return VipLevel.vipLevel2;
      case 'com.shenghua.note.vip_3003':
        return VipLevel.vipLevel3;
      default:
        return null;
    }
  }

  /// Disposes the service by cancelling the purchase update subscription.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}