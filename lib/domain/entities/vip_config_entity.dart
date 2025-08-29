import 'package:equatable/equatable.dart';

class VipConfigEntity extends Equatable {
  final List<VipProduct> goods;

  const VipConfigEntity({
    required this.goods,
  });

  @override
  List<Object?> get props => [goods];
}

class VipProduct extends Equatable {
  final int id;
  final String productId;
  final VipLevel level;
  final int ocrLimit;
  final int noteCreateLimit;
  final int speechLimit;
  final int aiLimit;
  final ExportData exportData;
  final bool hasTemplate;
  final int period;
  final int price;

  const VipProduct({
    required this.id,
    required this.productId,
    required this.level,
    required this.ocrLimit,
    required this.noteCreateLimit,
    required this.speechLimit,
    required this.aiLimit,
    required this.exportData,
    required this.hasTemplate,
    required this.period,
    required this.price,
  });

  VipProduct copyWith({
    int? id,
    String? productId,
    VipLevel? level,
    int? ocrLimit,
    int? noteCreateLimit,
    int? speechLimit,
    int? aiLimit,
    ExportData? exportData,
    bool? hasTemplate,
    int? period,
    int? price,
  }) {
    return VipProduct(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      level: level ?? this.level,
      ocrLimit: ocrLimit ?? this.ocrLimit,
      noteCreateLimit: noteCreateLimit ?? this.noteCreateLimit,
      speechLimit: speechLimit ?? this.speechLimit,
      aiLimit: aiLimit ?? this.aiLimit,
      exportData: exportData ?? this.exportData,
      hasTemplate: hasTemplate ?? this.hasTemplate,
      period: period ?? this.period,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        level,
        ocrLimit,
        noteCreateLimit,
        speechLimit,
        aiLimit,
        exportData,
        hasTemplate,
        period,
        price,
      ];

  bool get isUnlimited => ocrLimit == -1;
  bool get hasUnlimitedNotes => noteCreateLimit == -1;
  bool get hasUnlimitedSpeech => speechLimit == -1;
  bool get hasUnlimitedAi => aiLimit == -1;
  bool get isSubscription => period > 0;
  String get priceText => '¥${(price / 100).toStringAsFixed(2)}';
  String get periodText {
    if (period == 0) return '一次性购买';
    if (period == 30) return '月订阅';
    return '$period天订阅';
  }
}

enum VipLevel {
  vipLevel0, // 普通用户
  vipLevel1, // 普通会员
  vipLevel2, // 高级会员
  vipLevel3, // 至尊会员
}

enum ExportData {
  none, // 禁止导出
  note, // 导出笔记
  setting, // 导出设置
  noteAndSetting, // 导出笔记+设置
  all, // 导出所有
}

extension VipLevelExtension on VipLevel {
  String get displayName {
    switch (this) {
      case VipLevel.vipLevel0:
        return '普通用户';
      case VipLevel.vipLevel1:
        return '普通会员';
      case VipLevel.vipLevel2:
        return '高级会员';
      case VipLevel.vipLevel3:
        return '至尊会员';
    }
  }

  String get apiValue {
    switch (this) {
      case VipLevel.vipLevel0:
        return 'VL_VIP_0';
      case VipLevel.vipLevel1:
        return 'VL_VIP_1';
      case VipLevel.vipLevel2:
        return 'VL_VIP_2';
      case VipLevel.vipLevel3:
        return 'VL_VIP_3';
    }
  }
}

extension ExportDataExtension on ExportData {
  String get apiValue {
    switch (this) {
      case ExportData.none:
        return 'None';
      case ExportData.note:
        return 'Note';
      case ExportData.setting:
        return 'Setting';
      case ExportData.noteAndSetting:
        return 'NoteAndSetting';
      case ExportData.all:
        return 'All';
    }
  }

  String get displayName {
    switch (this) {
      case ExportData.none:
        return '禁止导出';
      case ExportData.note:
        return '导出笔记';
      case ExportData.setting:
        return '导出设置';
      case ExportData.noteAndSetting:
        return '导出笔记+设置';
      case ExportData.all:
        return '导出所有';
    }
  }
}