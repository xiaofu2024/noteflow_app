// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vip_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VipConfigModel _$VipConfigModelFromJson(Map<String, dynamic> json) =>
    VipConfigModel(
      goodsModels: (json['goods'] as List<dynamic>)
          .map((e) => VipProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VipConfigModelToJson(VipConfigModel instance) =>
    <String, dynamic>{
      'goods': instance.goodsModels.map((e) => e.toJson()).toList(),
    };

VipProductModel _$VipProductModelFromJson(Map<String, dynamic> json) =>
    VipProductModel(
      id: (json['id'] as num).toInt(),
      productId: json['productId'] as String,
      levelEnum: VipProductModel._vipLevelFromString(json['level'] as String),
      ocrLimit: (json['ocrLimit'] as num).toInt(),
      noteCreateLimit: (json['noteCreateLimit'] as num).toInt(),
      speechLimit: (json['speechLimit'] as num).toInt(),
      aiLimit: (json['aiLimit'] as num).toInt(),
      exportDataEnum:
          VipProductModel._exportDataFromString(json['exportData'] as String),
      hasTemplate: json['hasTemplate'] as bool,
      period: (json['period'] as num).toInt(),
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$VipProductModelToJson(VipProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'ocrLimit': instance.ocrLimit,
      'noteCreateLimit': instance.noteCreateLimit,
      'speechLimit': instance.speechLimit,
      'aiLimit': instance.aiLimit,
      'hasTemplate': instance.hasTemplate,
      'period': instance.period,
      'price': instance.price,
      'level': VipProductModel._vipLevelToString(instance.levelEnum),
      'exportData':
          VipProductModel._exportDataToString(instance.exportDataEnum),
    };
