/// Generic API response wrapper.
///
/// Wrap every API call result in this type to give callers
/// a consistent way to handle success / error states without
/// throwing exceptions up the call-stack.
///
/// Usage (placeholder — HTTP call not implemented):
/// ```dart
/// ApiResponse<Issue> response = await repository.getIssue(id);
/// if (response.isSuccess) {
///   // use response.data
/// } else {
///   // show response.message
/// }
/// ```
class ApiResponse<T> {
  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
  });

  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;

  /// Creates a successful response carrying [data].
  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      statusCode: statusCode,
    );
  }

  /// Creates an error response with an optional [message] and [statusCode].
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() =>
      'ApiResponse(isSuccess: $isSuccess, statusCode: $statusCode, '
      'message: $message, data: $data)';
}
