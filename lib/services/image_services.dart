import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageServices {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the specified [source].
  /// Returns an [XFile] if an image is picked, or `null` if the user cancels.
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<List<XFile>?> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      return images;
    } catch (e) {
      debugPrint('Error picking images: $e');
      return null;
    }
  }

  /// Compresses the image file.
  /// Returns a [File] containing the compressed image.
  Future<File> compressImage(
    XFile imageFile, {
    int quality = 50,
    int targetWidth = 900,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image.');
      }

      // Resize the image
      final resizedImage = img.copyResize(image, width: targetWidth);

      // Compress the image
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      // Get a temporary directory
      final tempDir = await getTemporaryDirectory();

      // Create a new file path
      final compressedFilePath = path.join(
        tempDir.path,
        '${path.basenameWithoutExtension(imageFile.path)}_compressed.jpg',
      );

      // Save the compressed image
      final compressedFile = File(compressedFilePath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      rethrow;
    }
  }

  /// Compresses a list of image files.
  /// Returns a list of [File] containing the compressed images.
  Future<List<File>> compressImages(
    List<XFile> imageFiles, {
    int quality = 70,
    int targetWidth = 900,
  }) async {
    try {
      List<Future<File>> compressionFutures = imageFiles
          .map((image) =>
              compressImage(image, quality: quality, targetWidth: targetWidth))
          .toList();
      return await Future.wait(compressionFutures);
    } catch (e) {
      debugPrint('Error compressing images: $e');
      rethrow;
    }
  }

  /// Uploads the [file] to Firebase Storage under the [folder] directory.
  /// Returns the download URL of the uploaded image.
  Future<String> uploadImageToFirebase(File file, String folder) async {
    try {
      String fileName = path.basename(file.path);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('$folder/${timestamp}_$fileName');

      UploadTask uploadTask = storageRef.putFile(file);

      // Optionally, listen to upload progress
      // uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      //   double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      // Update progress UI if needed
      // });

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Uploads a list of files to Firebase Storage under the [folder] directory.
  /// Returns a list of download URLs of the uploaded images.
  Future<List<String>> uploadImagesToFirebase(
      List<File> files, String folder) async {
    try {
      List<Future<String>> uploadFutures =
          files.map((file) => uploadImageToFirebase(file, folder)).toList();
      return await Future.wait(uploadFutures);
    } catch (e) {
      debugPrint('Error uploading images: $e');
      rethrow;
    }
  }
}
