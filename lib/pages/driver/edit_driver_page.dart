import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../widgets/date_picker_widget.dart';
import '/models/driver.dart';
import '/services/firestore_services.dart';
import '/services/image_services.dart';
import '/widgets/custom_textformfield.dart';
import '/widgets/image_picker_widget.dart';
import '/app_const.dart';
import '/widgets/custom_filled_button.dart';

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
  late TextEditingController _idNumberController;
  late TextEditingController _birthDateController;
  late TextEditingController _patentGivenDateController;
  late TextEditingController _patentExpiryDateController;
  late TextEditingController _phoneNumberController;
  String? _selectedGender;

  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;
    _nameController = TextEditingController(text: driver.name);
    _surnameController = TextEditingController(text: driver.surname);
    _patronymicController = TextEditingController(text: driver.patronymic);
    _idNumberController = TextEditingController(text: driver.idNumber);
    _birthDateController = TextEditingController(
        text: DateFormat('dd.MM.yyyy').format(driver.birthDate.toDate()));
    _patentGivenDateController = TextEditingController(
        text: DateFormat('dd.MM.yyyy').format(driver.patentGivenDate.toDate()));
    _patentExpiryDateController = TextEditingController(
        text:
            DateFormat('dd.MM.yyyy').format(driver.patentExpiryDate.toDate()));
    _phoneNumberController = TextEditingController(text: driver.phoneNumber);
    _existingImageUrls = driver.imageUrls ?? [];
    _selectedGender = driver.gender;
  }

  Future<void> _updateDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final birthDate =
            DateFormat('dd.MM.yyyy').parse(_birthDateController.text);
        final patentGivenDate =
            DateFormat('dd.MM.yyyy').parse(_patentGivenDateController.text);
        final patentExpiryDate =
            DateFormat('dd.MM.yyyy').parse(_patentExpiryDateController.text);

        final updatedDriver = widget.driver.copyWith(
          updatedAt: Timestamp.now(),
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          patronymic: _patronymicController.text.trim().isEmpty
              ? null
              : _patronymicController.text.trim(),
          idNumber: _idNumberController.text.trim(),
          birthDate: Timestamp.fromDate(birthDate),
          gender: _selectedGender,
          patentGivenDate: Timestamp.fromDate(patentGivenDate),
          patentExpiryDate: Timestamp.fromDate(patentExpiryDate),
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
        Navigator.pop(context);
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
                      controller: _idNumberController,
                      labelText: 'Номер ID',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите номер ID'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      firstDate: DateTime(1950),
                      controller: _birthDateController,
                      labelText: 'Дата рождения',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату рождения'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Пол',
                      ),
                      value: _selectedGender,
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'Мужской',
                          child: Text('Мужской'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Женский',
                          child: Text('Женский'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Пожалуйста, выберите пол' : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _patentGivenDateController,
                      labelText: 'Дата выдачи патента',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Пожалуйста, введите дату выдачи патента'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _patentExpiryDateController,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                      labelText: 'Дата окончания патента',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Пожалуйста, введите дату окончания патента'
                          : null,
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
