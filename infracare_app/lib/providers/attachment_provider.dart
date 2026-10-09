import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/attachment_model.dart';
import '../repositories/attachment_repository.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  return AttachmentRepository();
});

// ---------------------------------------------------------------------------
// Attachment Provider
// ---------------------------------------------------------------------------

/// Manages the list of photo/video attachments for the current issue report.
final attachmentProvider =
    NotifierProvider.autoDispose<AttachmentNotifier, List<AttachmentModel>>(
  AttachmentNotifier.new,
);

class AttachmentNotifier extends AutoDisposeNotifier<List<AttachmentModel>> {
  int _idCounter = 0;

  @override
  List<AttachmentModel> build() => const [];

  // ---------------------------------------------------------------------------
  // Pick & add attachments
  // ---------------------------------------------------------------------------

  /// Adds a single file to the attachment list.
  Future<void> addFile(XFile file) async {
    final bytes = await file.readAsBytes();
    final item = AttachmentModel(
      id: '${++_idCounter}',
      localPath: file.path,
      fileName: file.name,
      bytes: bytes,
    );
    state = [...state, item];
  }

  /// Adds multiple files at once (from multi-image picker).
  Future<void> addFiles(List<XFile> files) async {
    for (final f in files) {
      await addFile(f);
    }
  }

  // ---------------------------------------------------------------------------
  // Remove & Clear
  // ---------------------------------------------------------------------------

  /// Removes a file by [id].
  void removeFile(String id) {
    state = state.where((a) => a.id != id).toList();
  }

  /// Clears all attachments.
  void clear() => state = const [];

  // ---------------------------------------------------------------------------
  // Upload attachments to backend for a created issue
  // ---------------------------------------------------------------------------

  /// Uploads all pending local attachments to the backend for [issueId].
  Future<List<AttachmentModel>> uploadAttachmentsForIssue(String issueId) async {
    final repo = ref.read(attachmentRepositoryProvider);
    final uploadedList = <AttachmentModel>[];

    for (int i = 0; i < state.length; i++) {
      final item = state[i];
      if (item.isUploaded) {
        uploadedList.add(item);
        continue;
      }

      _setUploading(item.id);
      final response = await repo.uploadAttachment(
        issueId,
        filePath: item.localPath,
        bytes: item.bytes,
        fileName: item.fileName,
      );
      if (response.isSuccess && response.data != null) {
        final uploadedItem = response.data!;
        uploadedList.add(uploadedItem);
        _setUploaded(item.id, uploadedItem.uploadedUrl ?? uploadedItem.localPath);
      } else {
        _setFailed(item.id, response.message ?? 'Upload failed');
      }
    }
    return uploadedList;
  }

  // ---------------------------------------------------------------------------
  // Upload lifecycle
  // ---------------------------------------------------------------------------

  void _setUploading(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(isUploading: true) else a,
    ];
  }

  void _setUploaded(String id, String remoteUrl) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(uploadedUrl: remoteUrl, isUploading: false)
        else
          a,
    ];
  }

  void _setFailed(String id, String error) {
    state = [
      for (final a in state)
        if (a.id == id)
          a.copyWith(isUploading: false, uploadError: error)
        else
          a,
    ];
  }

  /// Retries a failed upload for a specific issue.
  Future<void> retryUpload(String id, String issueId) async {
    final item = state.where((a) => a.id == id).firstOrNull;
    if (item == null) return;

    _setUploading(id);
    final repo = ref.read(attachmentRepositoryProvider);
    final response = await repo.uploadAttachment(
      issueId,
      filePath: item.localPath,
      bytes: item.bytes,
      fileName: item.fileName,
    );
    if (response.isSuccess && response.data != null) {
      final uploadedItem = response.data!;
      _setUploaded(id, uploadedItem.uploadedUrl ?? uploadedItem.localPath);
    } else {
      _setFailed(id, response.message ?? 'Upload failed');
    }
  }

  // ---------------------------------------------------------------------------
  // Derived helpers
  // ---------------------------------------------------------------------------

  bool get isAnyUploading => state.any((a) => a.isUploading);

  List<String> get uploadedUrls =>
      state.where((a) => a.isUploaded).map((a) => a.uploadedUrl!).toList();
}

/// Family provider to fetch attachments for an existing issue by issue ID.
final issueAttachmentsProvider = AsyncNotifierProviderFamily<
    IssueAttachmentsNotifier, List<AttachmentModel>, String>(
  IssueAttachmentsNotifier.new,
);

class IssueAttachmentsNotifier
    extends FamilyAsyncNotifier<List<AttachmentModel>, String> {
  @override
  Future<List<AttachmentModel>> build(String arg) async {
    if (arg.isEmpty) return const [];
    final repo = ref.read(attachmentRepositoryProvider);
    final response = await repo.getAttachments(arg);
    if (response.isSuccess) {
      return response.data ?? [];
    }
    return const [];
  }

  Future<void> refresh() => update((_) => build(arg));
}
