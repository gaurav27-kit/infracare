import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../core/network/api_response.dart';
import '../models/attachment_model.dart';

class AttachmentRepository {
  final ApiClient _apiClient;

  AttachmentRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  /// Fetches all attachments for a specific issue.
  Future<ApiResponse<List<AttachmentModel>>> getAttachments(String issueId) async {
    final response = await _apiClient.get(ApiConstants.issueAttachments(issueId));
    if (response.isSuccess && response.data != null) {
      final List<dynamic> list = response.data is List
          ? response.data as List<dynamic>
          : (response.data['data'] as List<dynamic>? ?? []);
      final attachments = list
          .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(attachments, statusCode: response.statusCode);
    }
    return ApiResponse.error(
      response.message ?? 'Failed to fetch attachments',
      statusCode: response.statusCode,
    );
  }

  /// Uploads an attachment file for a specific issue using Base64 Data URI or Multipart request.
  Future<ApiResponse<AttachmentModel>> uploadAttachment(
    String issueId, {
    String? filePath,
    List<int>? bytes,
    String? fileName,
  }) async {
    // If bytes are provided, post as JSON data URI for 100% web & mobile reliability
    if (bytes != null && bytes.isNotEmpty) {
      try {
        final base64Str = base64Encode(bytes);
        final name = fileName ??
            (filePath != null && filePath.isNotEmpty
                ? filePath.split('/').last.split('\\').last
                : 'attachment.jpg');
        final ext = name.split('.').last.toLowerCase();
        final mimeType = (ext == 'png')
            ? 'image/png'
            : (ext == 'webp')
                ? 'image/webp'
                : 'image/jpeg';
        final dataUri = 'data:$mimeType;base64,$base64Str';

        final response = await _apiClient.post(
          ApiConstants.issueAttachments(issueId),
          data: {
            'fileName': name,
            'fileUrl': dataUri,
            'fileType': mimeType,
          },
        );

        if (response.isSuccess && response.data != null) {
          final uploaded = AttachmentModel.fromJson(response.data as Map<String, dynamic>);
          return ApiResponse.success(uploaded, statusCode: response.statusCode);
        }
      } catch (_) {
        // Fallback to multipart
      }
    }

    final response = await _apiClient.upload(
      ApiConstants.issueAttachments(issueId),
      filePath: filePath ?? '',
      fileBytes: bytes,
      fileName: fileName,
      fileFieldName: 'file',
    );
    if (response.isSuccess && response.data != null) {
      final uploaded = AttachmentModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse.success(uploaded, statusCode: response.statusCode);
    }
    return ApiResponse.error(
      response.message ?? 'Failed to upload attachment',
      statusCode: response.statusCode,
    );
  }

  /// Deletes an attachment by ID.
  Future<ApiResponse<bool>> deleteAttachment(String attachmentId) async {
    final response = await _apiClient.delete(ApiConstants.attachmentDetail(attachmentId));
    if (response.isSuccess) {
      return ApiResponse.success(true, statusCode: response.statusCode);
    }
    return ApiResponse.error(
      response.message ?? 'Failed to delete attachment',
      statusCode: response.statusCode,
    );
  }
}
