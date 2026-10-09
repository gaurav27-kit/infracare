import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_response.dart';

/// HTTP client facade using [Dio] for the InfraCare REST API.
///
/// Handles GET, POST, PUT, DELETE, and Multipart File Uploads.
/// Parses backend response envelopes (`success`, `message`, `data`, `meta`)
/// and maps Dio exceptions into user-friendly [ApiResponse] instances.
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;

  Dio get dio => _dio;

  /// Performs a GET request.
  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  /// Performs a POST request.
  Future<ApiResponse<dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  /// Performs a PUT request.
  Future<ApiResponse<dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  /// Performs a DELETE request.
  Future<ApiResponse<dynamic>> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred: $e');
    }
  }

  /// Performs a Multipart file upload supporting both bytes (web & mobile) and file path.
  Future<ApiResponse<dynamic>> upload(
    String endpoint, {
    required String filePath,
    List<int>? fileBytes,
    String? fileName,
    String fileFieldName = 'file',
    Map<String, dynamic>? extraFields,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final resolvedFileName = fileName ??
          (filePath.isNotEmpty
              ? filePath.split('/').last.split('\\').last
              : 'attachment.jpg');

      MultipartFile multipartFile;
      if (fileBytes != null && fileBytes.isNotEmpty) {
        multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: resolvedFileName,
        );
      } else if (!kIsWeb && filePath.isNotEmpty) {
        multipartFile = await MultipartFile.fromFile(
          filePath,
          filename: resolvedFileName,
        );
      } else {
        return ApiResponse.error('No file data available to upload.');
      }

      final formData = FormData.fromMap({
        fileFieldName: multipartFile,
        ...?extraFields,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(
          contentType: ApiConstants.contentTypeMultipart,
        ),
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Upload failed: $e');
    }
  }

  /// Parses standardized backend response envelope `{ success, message, data, meta }`.
  ApiResponse<dynamic> _parseResponse(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final success = body['success'] as bool? ??
          (response.statusCode != null &&
              response.statusCode! >= 200 &&
              response.statusCode! < 300);
      final message = body['message'] as String? ?? 'Success';
      final data = body.containsKey('data') ? body['data'] : body;
      if (success) {
        return ApiResponse.success(data, statusCode: response.statusCode);
      } else {
        return ApiResponse.error(message, statusCode: response.statusCode);
      }
    } else {
      return ApiResponse.success(body, statusCode: response.statusCode);
    }
  }

  /// Maps Dio exception types to friendly user message [ApiResponse].
  ApiResponse<dynamic> _handleDioError(DioException e) {
    int? statusCode = e.response?.statusCode;
    String message = 'An error occurred';

    if (e.response?.data is Map<String, dynamic>) {
      message = (e.response!.data as Map<String, dynamic>)['message'] as String? ?? message;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error('Connection timed out. Please try again.', statusCode: statusCode);
      case DioExceptionType.connectionError:
        return ApiResponse.error('No Internet connection. Please check your network.', statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiResponse.error('Request cancelled.', statusCode: statusCode);
      case DioExceptionType.badResponse:
        if (statusCode == 404) {
          return ApiResponse.error(message.isNotEmpty ? message : 'Resource not found (404).', statusCode: 404);
        } else if (statusCode == 401) {
          return ApiResponse.error(message.isNotEmpty ? message : 'Unauthorized access (401).', statusCode: 401);
        } else if (statusCode != null && statusCode >= 500) {
          return ApiResponse.error(message.isNotEmpty ? message : 'Server error ($statusCode). Please try again later.', statusCode: statusCode);
        }
        return ApiResponse.error(message, statusCode: statusCode);
      default:
        return ApiResponse.error(e.message ?? 'Network error occurred.', statusCode: statusCode);
    }
  }
}
