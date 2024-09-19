import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truck_fleet_app/app_const.dart';
import '/services/image_services.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(List<XFile>)? onImagesSelected;
  final List<XFile>? initialImages;
  final String title;

  const ImagePickerWidget({
    super.key,
    this.onImagesSelected,
    this.initialImages,
    this.title = 'Загрузить документы',
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImageServices _imageServices = ImageServices();
  late List<XFile> _selectedImages;

  @override
  void initState() {
    super.initState();
    _selectedImages = widget.initialImages ?? [];
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile>? images = await _imageServices.pickMultipleImages();

      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
        widget.onImagesSelected?.call(_selectedImages);
      }
    } else if (source == ImageSource.camera) {
      final XFile? image = await _imageServices.pickImage(source);

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
        widget.onImagesSelected?.call(_selectedImages);
      }
    }
  }

  Widget _buildSelectedImages() {
    return _selectedImages.isEmpty
        ? const SizedBox()
        : Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _selectedImages.map((image) {
              return Stack(
                children: [
                  Image.file(
                    File(image.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: -10,
                    top: -10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedImages.remove(image);
                        });
                        widget.onImagesSelected?.call(_selectedImages);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppConst.mediumSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Камера'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Галерея'),
            ),
          ],
        ),
        AppConst.mediumSpace,
        _buildSelectedImages(),
      ],
    );
  }
}
