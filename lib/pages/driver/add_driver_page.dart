import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/models/driver.dart';
import '/services/firestore_services.dart';
import '/services/image_services.dart';
import '/widgets/custom_textformfield.dart';
import '/widgets/image_picker_widget.dart';
import '/app_const.dart';
import '/widgets/custom_filled_button.dart';

class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key});

  @override
  State<AddDriverPage> createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final ImageServices _imageServices = ImageServices();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _patronymicController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  Future<void> _uploadImagesAndUpdateDriver(String driverId) async {
    try {
      List<String> imageUrls = [];

      List<Future<String>> uploadFutures = _selectedImages.map((image) async {
        final File compressedFile = await _imageServices.compressImage(image);
        String imageUrl = await _imageServices.uploadImageToFirebase(
            compressedFile, 'drivers');
        return imageUrl;
      }).toList();

      imageUrls = await Future.wait(uploadFutures);

      await _firestoreServices.updateDriverImages(driverId, imageUrls);
    } catch (e) {
      debugPrint('Error uploading images: $e');
    }
  }

  Future<void> _addDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final driverId =
            FirebaseFirestore.instance.collection('drivers').doc().id;
        final driver = Driver(
          id: driverId,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          patronymic: _patronymicController.text.trim().isEmpty
              ? null
              : _patronymicController.text.trim(),
          idNumber: _idNumberController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          imageUrls: [],
        );

        await _firestoreServices.addDriver(driver);

        _uploadImagesAndUpdateDriver(driver.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: _selectedImages.isNotEmpty
                  ? const Text(
                      'Водитель добавлен успешно! Изображения загружаются в фоновом режиме.')
                  : const Text('Водитель добавлен успешно!')),
        );
        Navigator.pop(context);
      } catch (e) {
        debugPrint('Error adding driver: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Произошла ошибка при добавлении водителя.')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _idNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить водителя'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _surnameController,
                labelText: 'Фамилия',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите фамилию';
                  }
                  return null;
                },
              ),
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Имя',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _patronymicController,
                labelText: 'Отчество',
                textCapitalization: TextCapitalization.words,
              ),
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _idNumberController,
                labelText: 'Номер ID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите номер ID';
                  }
                  return null;
                },
              ),
              AppConst.smallSpace,
              CustomTextFormField(
                controller: _phoneNumberController,
                labelText: 'Номер телефона',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите номер телефона';
                  }

                  return null;
                },
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
                      onPressed: _addDriver,
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
