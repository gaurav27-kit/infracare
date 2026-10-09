class AttachmentModel {
  final String id;
  final String localPath;
  final String? uploadedUrl;
  final bool isUploading;
  final String? uploadError;
  final List<int>? bytes;
  final String? fileName;

  const AttachmentModel({
    required this.id,
    required this.localPath,
    this.uploadedUrl,
    this.isUploading = false,
    this.uploadError,
    this.bytes,
    this.fileName,
  });

  bool get isUploaded => uploadedUrl != null && uploadedUrl!.isNotEmpty;
  bool get hasFailed => uploadError != null;

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    final url = json['fileUrl'] as String? ?? json['uploadedUrl'] as String?;
    final name = json['fileName'] as String? ?? json['localPath'] as String? ?? '';
    return AttachmentModel(
      id: json['id'] as String? ?? '',
      localPath: json['localPath'] as String? ?? name,
      uploadedUrl: url,
      fileName: name.isNotEmpty ? name : null,
      isUploading: json['isUploading'] as bool? ?? false,
      uploadError: json['uploadError'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final name = fileName ?? (localPath.isNotEmpty ? localPath.split('/').last.split('\\').last : 'attachment.jpg');
    return {
      'id': id,
      'localPath': localPath,
      'fileName': name,
      if (uploadedUrl != null) 'uploadedUrl': uploadedUrl,
      if (uploadedUrl != null) 'fileUrl': uploadedUrl,
      'isUploading': isUploading,
      if (uploadError != null) 'uploadError': uploadError,
    };
  }

  AttachmentModel copyWith({
    String? id,
    String? localPath,
    String? uploadedUrl,
    bool? isUploading,
    String? uploadError,
    List<int>? bytes,
    String? fileName,
  }) {
    return AttachmentModel(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      isUploading: isUploading ?? this.isUploading,
      uploadError: uploadError ?? this.uploadError,
      bytes: bytes ?? this.bytes,
      fileName: fileName ?? this.fileName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          localPath == other.localPath &&
          uploadedUrl == other.uploadedUrl &&
          isUploading == other.isUploading &&
          uploadError == other.uploadError;

  @override
  int get hashCode =>
      id.hashCode ^
      localPath.hashCode ^
      uploadedUrl.hashCode ^
      isUploading.hashCode ^
      uploadError.hashCode;

  @override
  String toString() =>
      'AttachmentModel(id: $id, localPath: $localPath, uploadedUrl: $uploadedUrl, isUploading: $isUploading, uploadError: $uploadError)';
}
