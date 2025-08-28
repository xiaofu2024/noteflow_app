import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/vip_config_entity.dart';

part 'vip_config_model.g.dart';

@JsonSerializable(explicitToJson: true)
class VipConfigModel extends VipConfigEntity {
  @JsonKey(name: 'goods')
  final List<VipProductModel> goodsModels;

  const VipConfigModel({
    required this.goodsModels,
  }) : super(goods: goodsModels);

  factory VipConfigModel.fromJson(Map<String, dynamic> json) =>
      _$VipConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$VipConfigModelToJson(this);
}

@JsonSerializable()
class VipProductModel extends VipProduct {
  @JsonKey(name: 'level', fromJson: _vipLevelFromString, toJson: _vipLevelToString)
  final VipLevel levelEnum;
  
  @JsonKey(name: 'exportData', fromJson: _exportDataFromString, toJson: _exportDataToString)
  final ExportData exportDataEnum;

  const VipProductModel({
    required super.id,
    required super.productId,
    required this.levelEnum,
    required super.ocrLimit,
    required super.noteCreateLimit,
    required super.speechLimit,
    required super.aiLimit,
    required this.exportDataEnum,
    required super.hasTemplate,
    required super.period,
    required super.price,
  }) : super(
          level: levelEnum,
          exportData: exportDataEnum,
        );

  factory VipProductModel.fromJson(Map<String, dynamic> json) =>
      _$VipProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$VipProductModelToJson(this);

  static VipLevel _vipLevelFromString(String level) {
    switch (level) {
      case 'VL_VIP_0':
        return VipLevel.vipLevel0;
      case 'VL_VIP_1':
        return VipLevel.vipLevel1;
      case 'VL_VIP_2':
        return VipLevel.vipLevel2;
      case 'VL_VIP_3':
        return VipLevel.vipLevel3;
      default:
        return VipLevel.vipLevel0;
    }
  }

  static String _vipLevelToString(VipLevel level) {
    return level.apiValue;
  }

  static ExportData _exportDataFromString(String exportData) {
    switch (exportData) {
      case 'None':
        return ExportData.none;
      case 'Note':
        return ExportData.note;
      case 'Setting':
        return ExportData.setting;
      case 'NoteAndSetting':
        return ExportData.noteAndSetting;
      case 'All':
        return ExportData.all;
      default:
        return ExportData.none;
    }
  }

  static String _exportDataToString(ExportData exportData) {
    return exportData.apiValue;
  }
}