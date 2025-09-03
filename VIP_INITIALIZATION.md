# VIP配置初始化实现总结

## 概述

根据 `InAppPurchaseRules.md` 中的要求，我已经在App启动时实现了调用 `/v1/app/user/getIapConfig` 接口获取VIP配置的功能。

## 实现详情

### 1. VipManager增强 (`lib/core/services/vip_manager.dart`)

**新增方法：**
- `loadVipConfig()`: 从远程API加载VIP配置
- `initialize()`: 增强版初始化方法，会调用 `loadVipConfig()`

**API调用流程：**
```dart
Future<void> loadVipConfig() async {
  try {
    final vipRepository = GetIt.instance<VipRepository>();
    final result = await vipRepository.getIapConfig();
    
    result.fold(
      (failure) => debugPrint('Failed to load VIP config: ${failure.message}'),
      (config) => updateVipConfig(config),
    );
  } catch (e) {
    debugPrint('Error loading VIP config: $e');
  }
}
```

### 2. 依赖注入初始化 (`lib/core/services/dependency_injection.dart`)

在App启动时自动初始化VipManager：
```dart
// VIP Services
sl.registerLazySingleton<VipManager>(() => VipManager());
await sl<VipManager>().initialize(); // 这里会调用API获取配置
```

### 3. API服务 (`lib/data/datasources/remote/vip_api_service.dart`)

已存在的API服务会调用正确的接口：
```dart
@GET('/app/user/getIapConfig')
Future<ApiResponse<VipConfigModel>> getIapConfig();
```

基础URL: `https://shl-api.weletter01.com/v1`

### 4. 调试支持 (`lib/core/services/vip_debug_helper.dart`)

新增调试辅助工具，用于验证VIP配置是否正确加载：
- `printVipStatus()`: 打印当前VIP状态
- `printUsageStats()`: 打印使用统计
- `testPermissions()`: 测试所有权限检查
- `runAllChecks()`: 运行所有调试检查

在SplashPage中会调用 `VipDebugHelper.runAllChecks()` 来输出调试信息。

## 工作流程

1. **App启动** → `main()` → `initializeDependencies()`
2. **依赖注入** → 注册VipManager并调用 `initialize()`
3. **VIP初始化** → 调用 `loadVipConfig()`
4. **API调用** → 请求 `https://shl-api.weletter01.com/v1/app/user/getIapConfig`
5. **配置更新** → 成功时更新VIP配置，失败时使用默认配置
6. **调试输出** → 在SplashPage中输出调试信息（开发模式）

## API响应处理

根据 `InAppPurchaseRules.md` 中的API规格，系统会解析以下结构：
```json
{
  "status": { "code": 0, "group": 0, "message": "" },
  "data": {
    "goods": [
      {
        "id": 1,
        "productId": "com.shenghua.note.vip1",
        "level": "VL_VIP_1",
        "ocrLimit": -1,
        "noteCreateLimit": 10,
        "speechLimit": 10,
        "aiLimit": 5,
        "exportData": "Note",
        "hasTemplate": true,
        "period": 30,
        "price": 388
      }
    ]
  }
}
```

## 错误处理

- **网络错误**: 记录错误日志，继续使用缓存或默认配置
- **解析错误**: 记录错误日志，使用默认配置
- **配置为空**: 使用默认的免费用户配置

## 验证方式

在开发模式下，App启动时会在控制台输出以下调试信息：
- 当前VIP等级和状态
- 各功能的使用限制
- 权限检查结果
- 使用统计

## 影响的功能

一旦VIP配置加载成功，以下功能会立即生效：
- OCR文字识别限制检查
- 语音转文字限制检查  
- 笔记创建限制检查
- 数据导出权限检查
- VIP状态显示和弹窗提示

## 配置缓存

VIP配置会在以下情况下更新：
- App启动时自动调用API
- 订阅页面手动刷新
- 购买成功后更新状态

配置失败时会：
- 使用SharedPreferences中的缓存配置
- 或使用硬编码的默认配置确保App正常运行