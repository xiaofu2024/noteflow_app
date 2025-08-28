import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/vip_config_entity.dart';

abstract class VipRepository {
  Future<Either<Failure, VipConfigEntity>> getIapConfig();
  Future<Either<Failure, bool>> purchaseProduct(String productId);
  Future<Either<Failure, void>> restorePurchases();
  Future<Either<Failure, void>> validatePurchase(String receiptData);
}