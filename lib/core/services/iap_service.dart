import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/entities/vip_config_entity.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs from your MD file
  static const Set<String> _productIds = {
    'com.shenghua.note.vip_3001', // VIP 1
    'com.shenghua.note.vip_3002', // VIP 2
    'com.shenghua.note.vip_3003', // VIP 3
  };

  // Available products
  List<ProductDetails> availableProducts = [];
  
  // Purchase status callbacks
  Function(PurchaseDetails)? onPurchaseSuccess;
  Function(PurchaseDetails, String)? onPurchaseError;
  Function(PurchaseDetails)? onPurchasePending;
  Function(PurchaseDetails)? onPurchaseRestored;

  Future<bool> initialize() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw UnsupportedError('Only iOS and macOS are supported');
      }

      final bool isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        return false;
      }

      // Listen to purchase updates
      _subscription?.cancel(); // Cancel existing subscription if any
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {},
        onError: (error) {
          print('Purchase stream error: $error');
        },
      );

      // Load available products
      await loadProducts();

      return true;
    } catch (e) {
      print('IAP initialization error: $e');
      return false;
    }
  }

  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.error != null) {
        throw Exception('Failed to load products: ${response.error}');
      }

      availableProducts = response.productDetails;
      print('Loaded ${availableProducts.length} products');
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<bool> purchaseProduct(String productId) async {
    try {
      final ProductDetails? productDetails = availableProducts
          .firstWhere((product) => product.id == productId);

      if (productDetails == null) {
        throw Exception('Product not found: $productId');
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Restore purchases error: $e');
    }
  }

  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      print('Complete purchase error: $e');
    }
  }

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

  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase pending: ${purchaseDetails.productID}');
    onPurchasePending?.call(purchaseDetails);
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase successful: ${purchaseDetails.productID}');
    onPurchaseSuccess?.call(purchaseDetails);
    completePurchase(purchaseDetails);
  }

  void _handleRestoredPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase restored: ${purchaseDetails.productID}');
    onPurchaseRestored?.call(purchaseDetails);
    completePurchase(purchaseDetails);
  }

  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    final String error = purchaseDetails.error?.message ?? 'Unknown error';
    print('Purchase failed: ${purchaseDetails.productID}, Error: $error');
    onPurchaseError?.call(purchaseDetails, error);
    completePurchase(purchaseDetails);
  }

  void _handleCanceledPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase canceled: ${purchaseDetails.productID}');
    onPurchaseError?.call(purchaseDetails, 'Purchase canceled by user');
    completePurchase(purchaseDetails);
  }

  ProductDetails? getProductById(String productId) {
    try {
      return availableProducts.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

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

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}