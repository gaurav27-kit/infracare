import 'package:image_picker/image_picker.dart';

/// Service for selecting images from the device gallery or camera.
///
/// Wraps [ImagePicker] to provide a single access point for image
/// selection across the app.
///
/// ⚠️  Upload logic is NOT implemented here.
/// Once an [XFile] is obtained, pass it to the media upload
/// repository/API call during backend integration.
class ImagePickerService {
  ImagePickerService._();

  static final ImagePickerService instance = ImagePickerService._();

  final ImagePicker _picker = ImagePicker();

  /// Opens the device gallery and returns the selected image file,
  /// or `null` if the user cancelled the selection.
  Future<XFile?> pickFromGallery({
    double? maxWidth = 1920,
    double? maxHeight = 1920,
    int? imageQuality = 85,
  }) async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  /// Opens the device camera and returns the captured image file,
  /// or `null` if the user cancelled.
  Future<XFile?> captureFromCamera({
    double? maxWidth = 1920,
    double? maxHeight = 1920,
    int? imageQuality = 85,
  }) async {
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  /// Opens the gallery and allows selecting multiple images,
  /// returning an empty list if the user cancels.
  Future<List<XFile>> pickMultipleFromGallery({
    double? maxWidth = 1920,
    double? maxHeight = 1920,
    int? imageQuality = 85,
    int? limit,
  }) async {
    return _picker.pickMultiImage(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      limit: limit,
    );
  }
}
