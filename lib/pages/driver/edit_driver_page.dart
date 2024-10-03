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
import 'driver_list_page.dart';

class EditDriverPage extends StatefulWidget {
  final Driver driver;

  const EditDriverPage({super.key, required this.driver});

  @override
  State<EditDriverPage> createState() => _EditDriverPageState();
}

class _EditDriverPageState extends State<EditDriverPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreServices _firestoreServices = FirestoreServices();
  final ImageServices _imageServices = ImageServices();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _patronymicController;
  late TextEditingController _phoneNumberController;
  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver.name);
    _surnameController = TextEditingController(text: widget.driver.surname);
    _patronymicController =
        TextEditingController(text: widget.driver.patronymic);
    _phoneNumberController =
        TextEditingController(text: widget.driver.phoneNumber);
    _existingImageUrls = widget.driver.imageUrls ?? [];
  }

  Future<void> _updateDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final updatedDriver = widget.driver.copyWith(
          updatedAt: Timestamp.now(),
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          patronymic: _patronymicController.text.trim().isEmpty
              ? null
              : _patronymicController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          imageUrls: _existingImageUrls,
        );

        await _firestoreServices.updateDriver(updatedDriver);

        if (_selectedImages.isNotEmpty) {
          await _uploadImagesAndUpdateDriver();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Водитель обновлен успешно!')),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverListPage(),
            ));
      } catch (e) {
        debugPrint('Error updating driver: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при обновлении водителя.')),
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

  Future<void> _uploadImagesAndUpdateDriver() async {
    try {
      List<String> imageUrls = [];

      List<Future<String>> uploadFutures = _selectedImages.map((image) async {
        final File compressedFile = await _imageServices.compressImage(image);
        String imageUrl = await _imageServices.uploadImageToFirebase(
            compressedFile, 'drivers');
        return imageUrl;
      }).toList();

      imageUrls = await Future.wait(uploadFutures);

      // Update the driver with new image URLs
      _existingImageUrls.addAll(imageUrls);
      await _firestoreServices.updateDriverImages(
          widget.driver.id, _existingImageUrls);
    } catch (e) {
      debugPrint('Error uploading images: $e');
      // Optionally notify the user about the failure
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать водителя'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _surnameController,
                      labelText: 'Фамилия',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value!.isEmpty ? 'Пожалуйста, введите фамилию' : null,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _nameController,
                      labelText: 'Имя',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          value!.isEmpty ? 'Пожалуйста, введите имя' : null,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _patronymicController,
                      labelText: 'Отчество',
                      textCapitalization: TextCapitalization.words,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _phoneNumberController,
                      labelText: 'Номер телефона',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите номер телефона'
                          : null,
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
                    AppConst.smallSpace,
                    CustomFilledButton(
                      onPressed: _updateDriver,
                      title: 'РЕДАКТИРОВАТЬ',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
