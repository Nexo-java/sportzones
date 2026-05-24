/// Generic API response wrapper
class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  BaseResponse({required this.success, this.message, this.data, this.errors});

  factory BaseResponse.fromMap(
    Map<String, dynamic> map,
    T Function(dynamic)? fromMapT,
  ) {
    return BaseResponse(
      success: map['success'] ?? false,
      message: map['message'],
      data: map['data'] != null && fromMapT != null
          ? fromMapT(map['data'])
          : null,
      errors: map['errors'],
    );
  }
}
