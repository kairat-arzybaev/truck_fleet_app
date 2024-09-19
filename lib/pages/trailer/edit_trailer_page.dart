// lib/pages/edit_trailer_page.dart

import 'package:flutter/material.dart';
import '/models/trailer.dart';
import '/services/firestore_services.dart';
import '/widgets/image_picker_widget.dart';
import 'package:image_picker/image_picker.dart';
import '/services/image_services.dart';
import 'dart:io';

class EditTrailerPage extends StatefulWidget {
  final Trailer trailer;

  const EditTrailerPage({Key? key, required this.trailer}) : super(key: key);

  @override
  _EditTrailerPageState createState() => _EditTrailerPageState();
}

class _EditTrailerPageState extends State<EditTrailerPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreServices _firestoreServices = FirestoreServices();
  final ImageServices _imageServices = ImageServices();

  late TextEditingController _makerController;
  late TextEditingController _modelController;
  late TextEditingController _plateNumberController;
  late TextEditingController _vinController;
  TrailerType? _selectedTrailerType;
  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _makerController = TextEditingController(text: widget.trailer.maker);
    _modelController = TextEditingController(text: widget.trailer.model);
    _plateNumberController = TextEditingController(text: widget.trailer.plateNumber);
    _vinController = TextEditingController(text: widget.trailer.vin);
    _selectedTrailerType = widget.trailer.type;
    _existingImageUrls = widget.trailer.registrationCertificateUrls!;
  }

  Future<void> _updateTrailer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final trailer = Trailer(
          id: widget.trailer.id,
          createdAt: widget.trailer.createdAt,
          updatedAt: DateTime.now(),
          maker: _makerController.text.trim(),
          model: _modelController.text.trim(),
          plateNumber: _plateNumberController.text.trim(),
          vin: _vinController.text.trim(),
          type: _selectedTrailerType!,
          registrationCertificateUrls: _existingImageUrls,
        );

        await _firestoreServices.updateTrailer(trailer);

        if (_selectedImages.isNotEmpty) {
          await _uploadImagesAndUpdateTrailer();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Прицеп обновлен успешно!')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error updating trailer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при обновлении прицепа.')),
        );
      } finally {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadImagesAndUpdateTrailer() async {
    try {
      List<String> imageUrls = [];

      List<Future<String>> uploadFutures = _selectedImages.map((image) async {
        final File compressedFile = await _imageServices.compressImage(image);
        String imageUrl = await _imageServices.uploadImageToFirebase(
            compressedFile, 'trailers');
        return imageUrl;
      }).toList();

      imageUrls = await Future.wait(uploadFutures);

      // Update the trailer with new image URLs
      _existingImageUrls.addAll(imageUrls);
      await _firestoreServices.updateTrailerImages(widget.trailer.id, _existingImageUrls);
    } catch (e) {
      print('Error uploading images: $e');
    }
  }

  @override
  void dispose() {
    _makerController.dispose();
    _modelController.dispose();
    _plateNumberController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать прицеп'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Form fields
                    TextFormField(
                      controller: _makerController,
                      decoration: const InputDecoration(labelText: 'Марка'),
                      validator: (value) => value!.isEmpty ? 'Введите марку' : null,
                    ),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Модель'),
                      validator: (value) => value!.isEmpty ? 'Введите модель' : null,
                    ),
                    TextFormField(
                      controller: _plateNumberController,
                      decoration: const InputDecoration(labelText: 'Номерной знак'),
                      validator: (value) => value!.isEmpty ? 'Введите номерной знак' : null,
                    ),
                    TextFormField(
                      controller: _vinController,
                      decoration: const InputDecoration(labelText: 'VIN'),
                      validator: (value) => value!.isEmpty ? 'Введите VIN' : null,
                    ),
                    // Trailer type dropdown
                    DropdownButtonFormField<TrailerType>(
                      value: _selectedTrailerType,
                      decoration: const InputDecoration(labelText: 'Тип прицепа'),
                      items: TrailerType.values.map((type) {
                        return DropdownMenuItem<TrailerType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTrailerType = value;
                        });
                      },
                      validator: (value) => value == null ? 'Выберите тип прицепа' : null,
                    ),
                    const SizedBox(height: 16),
                    // Existing images
                    if (_existingImageUrls.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Существующие документы:'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _existingImageUrls.map((url) {
                              return Stack(
                                children: [
                                  Image.network(
                                    url,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  // Optionally add delete functionality for images
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    // ImagePickerWidget for new images
                    ImagePickerWidget(
                      onImagesSelected: (images) {
                        _selectedImages = images;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateTrailer,
                      child: const Text('ОБНОВИТЬ'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
