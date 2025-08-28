import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/vip_config_model.dart';
import '../../../core/network/api_response.dart';

part 'vip_api_service.g.dart';

@RestApi(baseUrl: 'https://shl-api.weletter01.com/v1')
abstract class VipApiService {
  factory VipApiService(Dio dio, {String baseUrl}) = _VipApiService;

  @GET('/app/user/getIapConfig')
  Future<ApiResponse<VipConfigModel>> getIapConfig();
}