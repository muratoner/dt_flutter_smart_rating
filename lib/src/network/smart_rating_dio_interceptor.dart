import 'package:dio/dio.dart';
import '../core/smart_rating.dart';

class SmartRatingDioInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if response is successful (2xx)
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      SmartRating().reportNetworkSuccess();
    } else {
      SmartRating().reportNetworkFailure();
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    SmartRating().reportNetworkFailure();
    super.onError(err, handler);
  }
}
