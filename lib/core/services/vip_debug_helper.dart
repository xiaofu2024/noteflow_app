import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'vip_manager.dart';
import 'iap_service.dart';
import '../../domain/entities/vip_config_entity.dart';

/// Debug helper class for VIP functionality testing
class VipDebugHelper {
  static final VipManager _vipManager = GetIt.instance<VipManager>();
  static final IAPService _iapService = IAPService();

  /// Print current VIP status and configuration
  static void printVipStatus() {
    if (!kDebugMode) return;

    debugPrint('=== VIP Debug Status ===');
    
    // Check if VIP config is loaded
    if (_vipManager.currentVipConfig == null) {
      debugPrint('ERROR: VIP config is null - not initialized yet');
      return;
    }
    
    if (_vipManager.currentVipConfig!.goods.isEmpty) {
      debugPrint('ERROR: VIP config goods list is empty');
      return;
    }
    
    debugPrint('VIP Config loaded with ${_vipManager.currentVipConfig!.goods.length} products');
    
    final currentLevel = _vipManager.getCurrentVipLevel();
    final isVipActive = _vipManager.isVipActive;
    final expireTime = _vipManager.getVipExpireTime();
    final currentProduct = _vipManager.getCurrentVipProduct();
    
    debugPrint('Current VIP Level: ${currentLevel.displayName}');
    debugPrint('Is VIP Active: $isVipActive');
    debugPrint('Expire Time: $expireTime');
    
    if (currentProduct != null) {
      debugPrint('--- Current Product Details ---');
      debugPrint('Product ID: ${currentProduct.productId}');
      debugPrint('OCR Limit: ${currentProduct.ocrLimit} (unlimited: ${currentProduct.isUnlimited})');
      debugPrint('Note Create Limit: ${currentProduct.noteCreateLimit} (unlimited: ${currentProduct.hasUnlimitedNotes})');
      debugPrint('Speech Limit: ${currentProduct.speechLimit} (unlimited: ${currentProduct.hasUnlimitedSpeech})');
      debugPrint('AI Limit: ${currentProduct.aiLimit} (unlimited: ${currentProduct.hasUnlimitedAi})');
      debugPrint('Export Permission: ${currentProduct.exportData.displayName}');
      debugPrint('Price: ${currentProduct.priceText}');
      debugPrint('Period: ${currentProduct.periodText}');
    } else {
      debugPrint('Current Product: null (VIP config not loaded)');
    }
    
    // IAP Service status
    debugPrint('--- IAP Service Status ---');
    debugPrint('Available Products: ${_iapService.availableProducts.length}');
    debugPrint('Product IDs: ${_iapService.availableProducts.map((p) => p.id).toList()}');
    
    debugPrint('======================');
  }

  /// Print current usage statistics
  static Future<void> printUsageStats() async {
    if (!kDebugMode) return;

    debugPrint('=== Usage Statistics ===');
    
    final ocrUsage = await _vipManager.getOCRUsageCount();
    final noteCreateUsage = await _vipManager.getNoteCreateCount();
    final speechUsage = await _vipManager.getSpeechUsageCount();
    final aiUsage = await _vipManager.getAIUsageCount();
    
    debugPrint('OCR Usage Today: $ocrUsage');
    debugPrint('Note Create Usage Today: $noteCreateUsage');
    debugPrint('Speech Usage Today: $speechUsage');
    debugPrint('AI Usage Today: $aiUsage');
    
    debugPrint('========================');
  }

  /// Test all permission checks
  static Future<void> testPermissions() async {
    if (!kDebugMode) return;

    debugPrint('=== Permission Tests ===');
    
    final canUseOCR = await _vipManager.canUseOCR();
    final canCreateNote = await _vipManager.canCreateNote();
    final canUseSpeech = await _vipManager.canUseSpeechToText();
    final canUseAI = await _vipManager.canUseAI();
    final canExportNote = _vipManager.canExport(ExportData.note);
    final canExportSetting = _vipManager.canExport(ExportData.setting);
    final canExportAll = _vipManager.canExport(ExportData.all);
    
    debugPrint('Can Use OCR: $canUseOCR');
    debugPrint('Can Create Note: $canCreateNote');
    debugPrint('Can Use Speech: $canUseSpeech');
    debugPrint('Can Use AI: $canUseAI');
    debugPrint('Can Export Note: $canExportNote');
    debugPrint('Can Export Setting: $canExportSetting');
    debugPrint('Can Export All: $canExportAll');
    
    debugPrint('========================');
  }

  /// Simulate usage recording
  static Future<void> simulateUsage() async {
    if (!kDebugMode) return;

    debugPrint('=== Simulating Usage ===');
    
    await _vipManager.recordOCRUsage();
    await _vipManager.recordNoteCreation();
    await _vipManager.recordSpeechUsage();
    await _vipManager.recordAIUsage();
    
    debugPrint('Recorded 1 usage for each feature');
    debugPrint('========================');
  }

  /// Run all debug checks
  static Future<void> runAllChecks() async {
    printVipStatus();
    await printUsageStats();
    await testPermissions();
  }
}