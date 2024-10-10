import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:truck_fleet_app/services/image_services.dart';

import '/app_const.dart';
import '/widgets/custom_textformfield.dart';
import '/models/driver.dart';
import '/models/trailer.dart';
import '/models/vehicle.dart';
import '/services/firestore_services.dart';
import '/widgets/custom_filled_button.dart';
import '/widgets/date_picker_widget.dart';
import '/widgets/image_picker_widget.dart';

class EditVehiclePage extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehiclePage({super.key, required this.vehicle});

  @override
  State<EditVehiclePage> createState() => _EditVehiclePageState();
}

class _EditVehiclePageState extends State<EditVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreServices _firestoreServices = FirestoreServices();
  final ImageServices _imageServices = ImageServices();

  // Controllers
  late TextEditingController _makerController;
  late TextEditingController _modelController;
  late TextEditingController _plateNumberController;
  late TextEditingController _yearManufacturedController;
  late TextEditingController _engineCapacityController;
  late TextEditingController _mileageController;
  late TextEditingController _vinController;
  late TextEditingController _osagoGivenDateController;
  late TextEditingController _osagoExpiryDateController;
  late TextEditingController _insuranceGivenDateRuController;
  late TextEditingController _insuranceExpiryDateRuController;

  late TextEditingController _insuranceGivenDateKzController;
  late TextEditingController _insuranceExpiryDateKzController;
  late TextEditingController _licenceGivenDateController;
  late TextEditingController _licenceExpiryDateController;
  late TextEditingController _inspectionGivenDateController;
  late TextEditingController _inspectionExpiryDateController;
  late TextEditingController _passGivenDateController;
  late TextEditingController _passExpiryDateController;
  late TextEditingController _permitGivenDateController;
  late TextEditingController _permitExpiryDateController;

  late TextEditingController _ownerController;

  // State variables
  String? _selectedColor;

  late Trailer _selectedTrailer;
  late Driver _selectedDriver;
  bool _isLoading = false;
  List<String> _existingImageUrls = [];
  List<XFile> _selectedImages = [];

  // Lists for dropdowns
  List<Trailer> _trailers = [];
  bool _isLoadingTrailers = true;

  List<Driver> _drivers = [];
  bool _isLoadingDrivers = true;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;

    // Initialize controllers with existing data
    _makerController = TextEditingController(text: vehicle.maker);
    _modelController = TextEditingController(text: vehicle.model);
    _plateNumberController = TextEditingController(text: vehicle.plateNumber);
    _yearManufacturedController =
        TextEditingController(text: vehicle.yearManufactured);
    _engineCapacityController =
        TextEditingController(text: vehicle.engineCapacity.toString());
    _mileageController =
        TextEditingController(text: vehicle.mileage.toString());
    _vinController = TextEditingController(text: vehicle.vin);
    _osagoGivenDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(vehicle.osagoGivenDate.toDate()),
    );
    _osagoExpiryDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(vehicle.osagoExpiryDate.toDate()),
    );
    _insuranceGivenDateRuController = TextEditingController(
      text: DateFormat('dd.MM.yyyy')
          .format(vehicle.insuranceCertificateGivenDateRu.toDate()),
    );
    _insuranceExpiryDateRuController = TextEditingController(
      text: DateFormat('dd.MM.yyyy')
          .format(vehicle.insuranceCertificateExpiryDateRu.toDate()),
    );

    _insuranceGivenDateKzController = TextEditingController(
      text: DateFormat('dd.MM.yyyy')
          .format(vehicle.insuranceCertificateGivenDateKz.toDate()),
    );
    _insuranceExpiryDateKzController = TextEditingController(
      text: DateFormat('dd.MM.yyyy')
          .format(vehicle.insuranceCertificateExpiryDateKz.toDate()),
    );

    _licenceGivenDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(vehicle.licenceGivenDate.toDate()),
    );
    _licenceExpiryDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(vehicle.licenceExpiryDate.toDate()),
    );
    _inspectionGivenDateController = TextEditingController(
      text:
          DateFormat('dd.MM.yyyy').format(vehicle.inspectionGivenDate.toDate()),
    );
    _inspectionExpiryDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy')
          .format(vehicle.inspectionExpiryDate.toDate()),
    );
    _passGivenDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(vehicle.passGivenDate.toDate()),
    );
    _passExpiryDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(vehicle.passExpiryDate.toDate()),
    );
    _permitGivenDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(vehicle.permitGivenDate.toDate()),
    );
    _permitExpiryDateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(vehicle.permitExpiryDate.toDate()),
    );
    _ownerController = TextEditingController(text: vehicle.owner);
    _selectedColor = vehicle.color;

    _selectedTrailer = vehicle.trailer;
    _selectedDriver = vehicle.driver;
    _existingImageUrls = vehicle.imageUrls;

    // Fetch trailers and drivers
    _fetchTrailers();
    _fetchDrivers();
  }

  @override
  void dispose() {
    _makerController.dispose();
    _modelController.dispose();
    _plateNumberController.dispose();
    _yearManufacturedController.dispose();
    _engineCapacityController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    _insuranceGivenDateRuController.dispose();
    _insuranceExpiryDateRuController.dispose();

    _insuranceGivenDateKzController.dispose();
    _insuranceExpiryDateKzController.dispose();

    _licenceGivenDateController.dispose();
    _licenceExpiryDateController.dispose();
    _inspectionGivenDateController.dispose();
    _inspectionExpiryDateController.dispose();
    _passGivenDateController.dispose();
    _passExpiryDateController.dispose();
    _permitGivenDateController.dispose();
    _permitExpiryDateController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  void _fetchTrailers() async {
    try {
      _trailers = await _firestoreServices.getTrailersOnce();
      setState(() {
        _isLoadingTrailers = false;
      });
    } catch (e) {
      debugPrint('Error fetching trailers: $e');
      setState(() {
        _isLoadingTrailers = false;
      });
    }
  }

  void _fetchDrivers() async {
    try {
      _drivers = await _firestoreServices.getDriversOnce();
      setState(() {
        _isLoadingDrivers = false;
      });
    } catch (e) {
      debugPrint('Error fetching drivers: $e');
      setState(() {
        _isLoadingDrivers = false;
      });
    }
  }

  void _updateVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Parse date fields
        final insuranceGivenDateRu = DateFormat('dd.MM.yyyy')
            .parse(_insuranceGivenDateRuController.text);
        final insuranceExpiryDateRu = DateFormat('dd.MM.yyyy')
            .parse(_insuranceExpiryDateRuController.text);

        final insuranceGivenDateKz = DateFormat('dd.MM.yyyy')
            .parse(_insuranceGivenDateKzController.text);
        final insuranceExpiryDateKz = DateFormat('dd.MM.yyyy')
            .parse(_insuranceExpiryDateKzController.text);
        final licenceGivenDate =
            DateFormat('dd.MM.yyyy').parse(_licenceGivenDateController.text);
        final licenceExpiryDate =
            DateFormat('dd.MM.yyyy').parse(_licenceExpiryDateController.text);
        final inspectionGivenDate =
            DateFormat('dd.MM.yyyy').parse(_inspectionGivenDateController.text);
        final inspectionExpiryDate = DateFormat('dd.MM.yyyy')
            .parse(_inspectionExpiryDateController.text);
        final passGivenDate =
            DateFormat('dd.MM.yyyy').parse(_passGivenDateController.text);
        final passExpiryDate =
            DateFormat('dd.MM.yyyy').parse(_passExpiryDateController.text);
        final permitGivenDate =
            DateFormat('dd.MM.yyyy').parse(_permitGivenDateController.text);
        final permitExpiryDate =
            DateFormat('dd.MM.yyyy').parse(_permitExpiryDateController.text);

        // Create updated Vehicle object
        final updatedVehicle = widget.vehicle.copyWith(
          maker: _makerController.text.trim(),
          model: _modelController.text.trim(),
          plateNumber: _plateNumberController.text.trim(),
          yearManufactured: _yearManufacturedController.text.trim(),
          engineCapacity: double.parse(_engineCapacityController.text.trim()),
          color: _selectedColor,
          mileage: int.parse(_mileageController.text.trim()),
          vin: _vinController.text.trim(),
          insuranceCertificateGivenDateRu:
              Timestamp.fromDate(insuranceGivenDateRu),
          insuranceCertificateExpiryDateRu:
              Timestamp.fromDate(insuranceExpiryDateRu),
          insuranceCertificateGivenDateKz:
              Timestamp.fromDate(insuranceGivenDateKz),
          insuranceCertificateExpiryDateKz:
              Timestamp.fromDate(insuranceExpiryDateKz),
          licenceGivenDate: Timestamp.fromDate(licenceGivenDate),
          licenceExpiryDate: Timestamp.fromDate(licenceExpiryDate),
          inspectionGivenDate: Timestamp.fromDate(inspectionGivenDate),
          inspectionExpiryDate: Timestamp.fromDate(inspectionExpiryDate),
          passGivenDate: Timestamp.fromDate(passGivenDate),
          passExpiryDate: Timestamp.fromDate(passExpiryDate),
          permitGivenDate: Timestamp.fromDate(permitGivenDate),
          permitExpiryDate: Timestamp.fromDate(permitExpiryDate),
          trailer: _selectedTrailer,
          driver: _selectedDriver,
          owner: _ownerController.text.trim(),
          imageUrls: _existingImageUrls,
          updatedAt: Timestamp.now(),
        );

        // Update vehicle in Firestore
        await _firestoreServices.updateVehicle(updatedVehicle);
        if (_selectedImages.isNotEmpty) {
          await _uploadImagesAndUpdateVehicle();
        }
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фура обновлена успешно!')),
        );

        Navigator.pop(context);
      } catch (e) {
        debugPrint('Error updating vehicle: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при обновлении фуры.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadImagesAndUpdateVehicle() async {
    try {
      List<String> imageUrls = [];

      List<Future<String>> uploadFutures = _selectedImages.map((image) async {
        final File compressedFile = await _imageServices.compressImage(image);
        String imageUrl = await _imageServices.uploadImageToFirebase(
            compressedFile, 'vehicles');
        return imageUrl;
      }).toList();

      imageUrls = await Future.wait(uploadFutures);

      // Update the driver with new image URLs
      _existingImageUrls.addAll(imageUrls);
      await _firestoreServices.updateVehicleImages(
          widget.vehicle.id, _existingImageUrls);
    } catch (e) {
      debugPrint('Error uploading images: $e');
      // Optionally notify the user about the failure
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime firstDate = DateTime.now();
    final DateTime lastDate = DateTime.now().add(const Duration(days: 5 * 365));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать фуру'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _plateNumberController,
                      labelText: 'Номерной знак',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите номерной знак'
                          : null,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _yearManufacturedController,
                      labelText: 'Год выпуска',
                      validator: (value) =>
                          value!.isEmpty ? 'Пожалуйста, введите год' : null,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _engineCapacityController,
                      labelText: 'Объем двигателя',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите объем двигателя'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Цвет',
                      ),
                      value: _selectedColor,
                      items: AppConst.colorOptions.map((String color) {
                        return DropdownMenuItem<String>(
                          value: color,
                          child: Text(color),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedColor = newValue!;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Пожалуйста, выберите цвет' : null,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _mileageController,
                      labelText: 'Пробег',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      validator: (value) =>
                          value!.isEmpty ? 'Пожалуйста, введите пробег' : null,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _vinController,
                      labelText: 'VIN',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
                      ],
                      validator: (value) =>
                          value!.isEmpty ? 'Пожалуйста, введите VIN' : null,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _ownerController,
                      labelText: 'Владелец',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите владелца'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _osagoGivenDateController,
                      labelText: 'Дата выдачи ОСАГО',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату выдачи ОСАГО'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _osagoExpiryDateController,
                      labelText: 'Дата окончания ОСАГО',
                      firstDate: firstDate,
                      lastDate: lastDate,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату окончания ОСАГО'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _insuranceGivenDateRuController,
                      labelText: 'Дата выдачи страховки - Россия',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату выдачи страховки - Россия'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _insuranceExpiryDateRuController,
                      labelText: 'Дата окончания страховки - Россия',
                      firstDate: firstDate,
                      lastDate: lastDate,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату окончания страховки - Россия'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _insuranceGivenDateKzController,
                      labelText: 'Дата выдачи страховки - Казакстан',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату выдачи страховки - Казакстан'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _insuranceExpiryDateKzController,
                      labelText: 'Дата окончания страховки - Казакстан',
                      firstDate: firstDate,
                      lastDate: lastDate,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату окончания страховки - Казакстан'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _licenceGivenDateController,
                      labelText: 'Дата выдачи лицензии',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату выдачи лицензии'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _licenceExpiryDateController,
                      labelText: 'Дата окончания лицензии',
                      firstDate: firstDate,
                      lastDate: lastDate,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату окончания лицензии'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _inspectionGivenDateController,
                      labelText: 'Дата выдачи тех.осмотра',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату выдачи тех.осмотра'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _inspectionExpiryDateController,
                      labelText: 'Дата окончания тех.осмотра',
                      firstDate: firstDate,
                      lastDate: lastDate,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату окончания тех.осмотра'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _passGivenDateController,
                      labelText: 'Дата выдачи пропуска',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату выдачи пропуска'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _passExpiryDateController,
                      labelText: 'Дата окончания пропуска',
                      firstDate: firstDate,
                      lastDate: lastDate,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату окончания пропуска'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _permitGivenDateController,
                      labelText: 'Дата выдачи дозвола',
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату выдачи дозвола'
                          : null,
                    ),
                    AppConst.smallSpace,
                    DatePickerWidget(
                      controller: _permitExpiryDateController,
                      labelText: 'Дата окончания дозвола',
                      firstDate: firstDate,
                      lastDate: lastDate,
                      validator: (value) => value!.isEmpty
                          ? 'Пожалуйста, введите дату окончания дозвола'
                          : null,
                    ),
                    AppConst.smallSpace,
                    CustomTextFormField(
                      controller: _ownerController,
                      labelText: 'Владелец',
                    ),
                    AppConst.smallSpace,
                    _buildTrailerDropdown(),
                    AppConst.smallSpace,
                    _buildDriverDropdown(),
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
                      onPressed: () {
                        _isLoading ? null : _updateVehicle();
                      },
                      title: 'СОХРАНИТЬ',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTrailerDropdown() {
    if (_isLoadingTrailers) {
      return const CircularProgressIndicator();
    }

    if (_trailers.isEmpty) {
      return const Text('Нет доступных прицепов');
    }

    return DropdownButtonFormField<Trailer>(
      decoration: const InputDecoration(
        labelText: 'Выберите прицеп',
      ),
      value: _trailers.firstWhere(
        (trailer) => trailer.id == _selectedTrailer.id,
        orElse: () => _trailers.first,
      ),
      items: _trailers.map((trailer) {
        return DropdownMenuItem<Trailer>(
          value: trailer,
          child: Text(trailer.plateNumber),
        );
      }).toList(),
      onChanged: (Trailer? newValue) {
        setState(() {
          _selectedTrailer = newValue!;
        });
      },
      validator: (value) =>
          value == null ? 'Пожалуйста, выберите прицеп' : null,
    );
  }

  Widget _buildDriverDropdown() {
    if (_isLoadingDrivers) {
      return const CircularProgressIndicator();
    }

    if (_drivers.isEmpty) {
      return const Text('Нет доступных водителей');
    }

    return DropdownButtonFormField<Driver>(
      decoration: const InputDecoration(
        labelText: 'Выберите водителя',
      ),
      value: _drivers.firstWhere(
        (driver) => driver.id == _selectedDriver.id,
        orElse: () => _drivers.first,
      ),
      items: _drivers.map((driver) {
        return DropdownMenuItem<Driver>(
          value: driver,
          child: Text('${driver.name} ${driver.surname}'),
        );
      }).toList(),
      onChanged: (Driver? newValue) {
        setState(() {
          _selectedDriver = newValue!;
        });
      },
      validator: (value) =>
          value == null ? 'Пожалуйста, выберите водителя' : null,
    );
  }
}
