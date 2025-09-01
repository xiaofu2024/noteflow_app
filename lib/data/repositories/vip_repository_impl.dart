import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/vip_config_entity.dart';
import '../../domain/repositories/vip_repository.dart';
import '../datasources/remote/vip_api_service.dart';
import '../../core/services/iap_service.dart';

class VipRepositoryImpl implements VipRepository {
  final VipApiService apiService;
  final IAPService iapService;

  VipRepositoryImpl({
    required this.apiService,
    required this.iapService,
  });

  @override
  Future<Either<Failure, VipConfigEntity>> getIapConfig() async {
    try {
      final response = await apiService.getIapConfig();
      
      if (response.status.isSuccess) {
        return Right(response.data);
      } else {
        return Left(ServerFailure('Failed to get IAP config: ${response.status.message}'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> purchaseProduct(String productId) async {
    try {
      final success = await iapService.purchaseProduct(productId);
      return Right(success);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(e.message));
    } catch (e) {
      return Left(PurchaseFailure('Purchase failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> restorePurchases() async {
    try {
      final result = await iapService.restorePurchases();
      if (result['success'] == true) {
        return const Right(null);
      } else {
        return Left(PurchaseFailure(result['message'] ?? 'Restore failed'));
      }
    } catch (e) {
      return Left(PurchaseFailure('Restore failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> validatePurchase(String receiptData) async {
    try {
      // Here you would implement server-side receipt validation
      // For now, we'll just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Validation failed: $e'));
    }
  }
}