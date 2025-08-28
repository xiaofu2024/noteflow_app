class ApiResponse<T> {
  final ApiStatus status;
  final T data;

  const ApiResponse({
    required this.status,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      status: ApiStatus.fromJson(json['status'] as Map<String, dynamic>),
      data: fromJsonT(json['data']),
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'status': status.toJson(),
      'data': toJsonT(data),
    };
  }
}

class ApiStatus {
  final int code;
  final int group;
  final String message;

  const ApiStatus({
    required this.code,
    required this.group,
    required this.message,
  });

  factory ApiStatus.fromJson(Map<String, dynamic> json) {
    return ApiStatus(
      code: json['code'] as int,
      group: json['group'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'group': group,
      'message': message,
    };
  }

  bool get isSuccess => code == 0;
}