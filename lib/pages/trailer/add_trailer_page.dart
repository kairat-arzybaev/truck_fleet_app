import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '/widgets/image_picker_widget.dart';
import '/services/image_services.dart';
import '/widgets/custom_textformfield.dart';
import '/models/trailer.dart';
import '/services/firestore_services.dart';
import '/app_const.dart';
import '/widgets/custom_filled_button.dart';

class AddTrailerPage extends StatefulWidget {
  const AddTrailerPage({super.key});

  @override
  State<AddTrailerPage> createState() => _AddTrailerPageState();
}

class _AddTrailerPageState extends State<AddTrailerPage> {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final ImageServices _imageServices = ImageServices();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _makerController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearManufacteredController =
      TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();

  TrailerType? _selectedTrailerType;
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  final List<DropdownMenuItem<TrailerType>> trailerTypeDropdownItems =
      TrailerType.values.map((TrailerType type) {
    return DropdownMenuItem<TrailerType>(
      value: type,
      child: Text(type.displayName),
    );
  }).toList();

  Future<void> _uploadImagesAndUpdateTrailer(String trailerId) async {
    try {
      List<String> imageUrls = [];

      List<Future<String>> uploadFutures = _selectedImages.map((image) async {
        final File compressedFile = await _imageServices.compressImage(image);
        String imageUrl = await _imageServices.uploadImageToFirebase(
            compressedFile, 'trailers');
        return imageUrl;
      }).toList();

      imageUrls = await Future.wait(uploadFutures);

      await _firestoreServices.updateTrailerImages(trailerId, imageUrls);
    } catch (e) {
      debugPrint('Error uploading images: $e');
    }
  }

  Future<void> _addTrailer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final trailer = Trailer(
          id: FirebaseFirestore.instance.collection('trailers').doc().id,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          maker: _makerController.text.trim(),
          model: _modelController.text.trim(),
          yearManufactered: int.parse(_yearManufacteredController.text.trim()),
          plateNumber: _plateNumberController.text.trim(),
          vin: _vinController.text.trim(),
          type: _selectedTrailerType!,
          registrationCertificateUrls: [],
        );

        await _firestoreServices.addTrailer(trailer);

        _uploadImagesAndUpdateTrailer(trailer.id);

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Прицеп добавлен успешно!'),
          ),
        );
      } catch (e) {
        debugPrint('Error adding trailer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Произошла ошибка при добавлении прицепа.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
        title: const Text('Добавить прицеп'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _makerController,
                labelText: 'Марка',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите марку';
                  }
                  return null;
                },
              ),
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _modelController,
                labelText: 'Модель',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите модель';
                  }
                  return null;
                },
              ),
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _yearManufacteredController,
                labelText: 'Год выпуска',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите год выпуска';
                  }
                  return null;
                },
              ),
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _plateNumberController,
                labelText: 'Гос. номер',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите гос. номер';
                  }
                  return null;
                },
              ),
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _vinController,
                labelText: 'VIN',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите VIN';
                  }
                  return null;
                },
              ),
              AppConst.smallSpace,
              DropdownButtonFormField<TrailerType>(
                value: _selectedTrailerType,
                decoration: const InputDecoration(labelText: 'Тип прицепа'),
                items: trailerTypeDropdownItems,
                onChanged: (TrailerType? newValue) {
                  setState(() {
                    _selectedTrailerType = newValue!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Пожалуйста, выберите тип прицепа' : null,
              ),
              AppConst.mediumSpace,
              ImagePickerWidget(
                onImagesSelected: (images) {
                  setState(() {
                    _selectedImages = images;
                  });
                },
                initialImages: _selectedImages,
              ),
              AppConst.mediumSpace,
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomFilledButton(
                      onPressed: _addTrailer,
                      title: 'СОХРАНИТЬ',
                    ),
              AppConst.mediumSpace,
            ],
          ),
        ),
      ),
    );
  }
}
