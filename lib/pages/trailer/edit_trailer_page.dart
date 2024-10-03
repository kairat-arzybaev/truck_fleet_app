import 'package:flutter/material.dart';
import 'package:truck_fleet_app/app_const.dart';
import 'package:truck_fleet_app/pages/homepage.dart';
import 'package:truck_fleet_app/widgets/custom_filled_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/widgets/custom_textformfield.dart';
import '/models/trailer.dart';
import '/services/firestore_services.dart';
import '/widgets/image_picker_widget.dart';
import 'package:image_picker/image_picker.dart';
import '/services/image_services.dart';
import 'dart:io';

class EditTrailerPage extends StatefulWidget {
  final Trailer trailer;

  const EditTrailerPage({super.key, required this.trailer});

  @override
  State<EditTrailerPage> createState() => _EditTrailerPageState();
}

class _EditTrailerPageState extends State<EditTrailerPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreServices _firestoreServices = FirestoreServices();
  final ImageServices _imageServices = ImageServices();

  late TextEditingController _makerController;
  late TextEditingController _modelController;
  late TextEditingController _plateNumberController;
  late TextEditingController _vinController;
  late TextEditingController _yearManufacteredController;
  TrailerType? _selectedTrailerType;
  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _makerController = TextEditingController(text: widget.trailer.maker);
    _modelController = TextEditingController(text: widget.trailer.model);
    _yearManufacteredController =
        TextEditingController(text: widget.trailer.yearManufactered.toString());
    _plateNumberController =
        TextEditingController(text: widget.trailer.plateNumber);
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
        final updatedTrailer = widget.trailer.copyWith(
          updatedAt: Timestamp.now(),
          maker: _makerController.text.trim(),
          model: _modelController.text.trim(),
          yearManufactered: int.parse(_yearManufacteredController.text.trim()),
          plateNumber: _plateNumberController.text.trim(),
          vin: _vinController.text.trim(),
          type: _selectedTrailerType!,
          registrationCertificateUrls: _existingImageUrls,
        );

        await _firestoreServices.updateTrailer(updatedTrailer);

        if (_selectedImages.isNotEmpty) {
          await _uploadImagesAndUpdateTrailer();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Прицеп обновлен успешно!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        debugPrint('Error updating trailer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при обновлении прицепа.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadImagesAndUpdateTrailer() async {
    try {
      List<Future<String>> uploadFutures = _selectedImages.map((image) async {
        final File compressedFile = await _imageServices.compressImage(image);
        String imageUrl = await _imageServices.uploadImageToFirebase(
            compressedFile, 'trailers');
        return imageUrl;
      }).toList();

      List<String> imageUrls = await Future.wait(uploadFutures);

      // Update the trailer with new image URLs
      _existingImageUrls.addAll(imageUrls);
      await _firestoreServices.updateTrailerImages(
          widget.trailer.id, _existingImageUrls);
    } catch (e) {
      debugPrint('Error uploading images: $e');
    }
  }

  @override
  void dispose() {
    _makerController.dispose();
    _modelController.dispose();
    _yearManufacteredController.dispose();
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _makerController,
                      labelText: 'Марка',
                      validator: (value) =>
                          value!.isEmpty ? 'Пожалуйста, введите марку' : null,
                    ),

                    AppConst.smallSpace,

                    CustomTextFormField(
                      controller: _modelController,
                      labelText: 'Модель',
                      validator: (value) =>
                          value!.isEmpty ? 'Введите модель' : null,
                    ),
                    AppConst.smallSpace,

                    CustomTextFormField(
                      controller: _yearManufacteredController,
                      labelText: 'Год выпуска',
                      validator: (value) =>
                          value!.isEmpty ? 'Введите год выпуска' : null,
                    ),
                    AppConst.smallSpace,

                    CustomTextFormField(
                      controller: _plateNumberController,
                      labelText: 'Номерной знак',
                      validator: (value) =>
                          value!.isEmpty ? 'Введите номерной знак' : null,
                    ),
                    AppConst.smallSpace,

                    CustomTextFormField(
                      controller: _vinController,
                      labelText: 'VIN',
                      validator: (value) =>
                          value!.isEmpty ? 'Введите VIN' : null,
                    ),
                    AppConst.smallSpace,

                    // Trailer type dropdown
                    DropdownButtonFormField<TrailerType>(
                      value: _selectedTrailerType,
                      decoration:
                          const InputDecoration(labelText: 'Тип прицепа'),
                      items: TrailerType.values.map((type) {
                        return DropdownMenuItem<TrailerType>(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTrailerType = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Выберите тип прицепа' : null,
                    ),
                    AppConst.mediumSpace,

                    ImagePickerWidget(
                      onImagesSelected: (images) {
                        _selectedImages = images;
                      },
                    ),
                    AppConst.smallSpace,

                    CustomFilledButton(
                      onPressed: _updateTrailer,
                      title: 'РЕДАКТИРОВАТЬ',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
