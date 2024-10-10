import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:truck_fleet_app/app_const.dart';
import 'package:truck_fleet_app/services/firestore_services.dart';
import '/services/image_services.dart';
import '/models/vehicle.dart';
import '/widgets/date_picker_widget.dart';
import '/models/trailer.dart';
import '/models/driver.dart';
import '/widgets/custom_filled_button.dart';
import '/widgets/custom_textformfield.dart';
import '/widgets/image_picker_widget.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _makerController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _yearManufacturedController = TextEditingController();
  final _engineCapacityController = TextEditingController();
  final _mileageController = TextEditingController();
  final _vinController = TextEditingController();
  final _osagoGivenDateController = TextEditingController();
  final _osagoExpiryDateController = TextEditingController();
  final _insuranceGivenDateRuController = TextEditingController();
  final _insuranceExpiryDateRuController = TextEditingController();

  final _insuranceGivenDateKzController = TextEditingController();
  final _insuranceExpiryDateKzController = TextEditingController();
  final _licenceGivenDateController = TextEditingController();
  final _licenceExpiryDateController = TextEditingController();
  final _inspectionGivenDateController = TextEditingController();
  final _inspectionExpiryDateController = TextEditingController();
  final _passGivenDateController = TextEditingController();
  final _passExpiryDateController = TextEditingController();
  final _permitGivenDateController = TextEditingController();
  final _permitExpiryDateController = TextEditingController();
  final _ownerController = TextEditingController();

  final FirestoreServices _firestoreServices = FirestoreServices();
  final ImageServices _imageServices = ImageServices();
  List<XFile> _selectedImages = [];
  String? _selectedColor;

  List<Trailer> _trailers = [];
  Trailer? _selectedTrailer;
  List<Driver> _drivers = [];
  Driver? _selectedDriver;
  bool _isLoadingTrailers = true;
  bool _isLoadingDrivers = true;
  bool _isLoadingVehicle = false;

  @override
  void initState() {
    super.initState();
    _fetchTrailers();
    _fetchDrivers();
  }

  void _fetchTrailers() {
    _firestoreServices.getTrailers().listen(
      (trailers) {
        setState(() {
          _trailers = trailers;
          _isLoadingTrailers = false;
        });
      },
      onError: (error) {
        debugPrint('Error fetching trailers: $error');

        setState(() {
          _isLoadingTrailers = false;
        });
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при загрузке прицепов')),
        );
      },
    );
  }

  void _fetchDrivers() {
    _firestoreServices.getDrivers().listen(
      (drivers) {
        setState(() {
          _drivers = drivers;
          _isLoadingDrivers = false;
        });
      },
      onError: (error) {
        debugPrint('Error fetching drivers: $error');
        setState(() {
          _isLoadingTrailers = false;
        });
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при загрузке водителей')),
        );
      },
    );
  }

  Widget _buildTrailerDropdown() {
    if (_isLoadingTrailers) {
      return const Center(child: CircularProgressIndicator());
    } else if (_trailers.isEmpty) {
      return const Text('Нет доступных прицепов для выбора.');
    } else {
      return DropdownButtonFormField<Trailer>(
        decoration: const InputDecoration(
          labelText: 'Выберите прицеп',
        ),
        value: _selectedTrailer,
        items: _trailers.map((trailer) {
          return DropdownMenuItem<Trailer>(
            value: trailer,
            child: Text(trailer.plateNumber),
          );
        }).toList(),
        onChanged: (Trailer? newValue) {
          setState(() {
            _selectedTrailer = newValue;
          });
        },
        validator: (value) =>
            value == null ? 'Пожалуйста, выберите прицеп' : null,
      );
    }
  }

  Widget _buildDriverDropdown() {
    if (_isLoadingDrivers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_drivers.isEmpty) {
      return const Text('Нет доступных водителей для выбора.');
    }

    return DropdownButtonFormField<Driver>(
      decoration: const InputDecoration(
        labelText: 'Выберите водителя',
      ),
      value: _selectedDriver,
      items: _drivers.map((driver) {
        return DropdownMenuItem<Driver>(
          value: driver,
          child: Text('${driver.name} ${driver.surname}'),
        );
      }).toList(),
      onChanged: (Driver? newValue) {
        setState(() {
          _selectedDriver = newValue;
        });
      },
      validator: (value) =>
          value == null ? 'Пожалуйста, выберите водителя' : null,
    );
  }

  Future<void> _uploadImagesAndUpdateVehicle(String vehicleId) async {
    try {
      List<String> imageUrls = [];

      List<Future<String>> uploadFutures = _selectedImages.map((image) async {
        final File compressedFile = await _imageServices.compressImage(image);
        String imageUrl = await _imageServices.uploadImageToFirebase(
            compressedFile, 'vehicles');
        return imageUrl;
      }).toList();

      imageUrls = await Future.wait(uploadFutures);

      await _firestoreServices.updateVehicleImages(vehicleId, imageUrls);
    } catch (e) {
      debugPrint('Error uploading images: $e');
    }
  }

  void _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingVehicle = true;
      });

      try {
        // Generate a unique ID for the vehicle
        final vehicleId =
            FirebaseFirestore.instance.collection('vehicles').doc().id;

        // Parse date fields from controllers
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
            DateFormat('dd.MM.yyyy').parse(_passGivenDateController.text);
        final permitExpiryDate =
            DateFormat('dd.MM.yyyy').parse(_passExpiryDateController.text);
        final osagoGivenDate =
            DateFormat('dd.MM.yyyy').parse(_passGivenDateController.text);
        final osagoExpiryDate =
            DateFormat('dd.MM.yyyy').parse(_passExpiryDateController.text);

        // Create a new Vehicle instance
        final newVehicle = Vehicle(
          id: vehicleId,
          maker: _makerController.text.trim(),
          model: _modelController.text.trim(),
          plateNumber: _plateNumberController.text.trim(),
          yearManufactured: _yearManufacturedController.text.trim(), // String
          engineCapacity: double.parse(_engineCapacityController.text.trim()),
          color: _selectedColor!,
          mileage: int.parse(_mileageController.text.trim()),
          vin: _vinController.text.trim(),
          osagoGivenDate: Timestamp.fromDate(osagoGivenDate),
          osagoExpiryDate: Timestamp.fromDate(osagoExpiryDate),
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
          trailer: _selectedTrailer!,
          driver: _selectedDriver!,
          owner: _ownerController.text.trim(),
          imageUrls: [],
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        // Add the vehicle to Firestore
        await _firestoreServices.addVehicle(newVehicle);
        _uploadImagesAndUpdateVehicle(vehicleId);

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Транспортное средство добавлено успешно!')),
        );

        // Clear the form or navigate back
        Navigator.pop(context);
      } catch (e) {
        debugPrint('Error adding vehicle: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ошибка при добавлении транспортного средства.')),
        );
      } finally {
        setState(() {
          _isLoadingVehicle = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _makerController.dispose();
    _modelController.dispose();
    _yearManufacturedController.dispose();
    _engineCapacityController.dispose();
    _plateNumberController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    _osagoGivenDateController.dispose();
    _osagoExpiryDateController.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    final DateTime firstDate = DateTime.now();
    final DateTime lastDate = DateTime.now().add(const Duration(days: 5 * 365));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить фуру'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
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
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите год выпуска' : null,
                ),
                AppConst.smallSpace,
                CustomTextFormField(
                  controller: _engineCapacityController,
                  labelText: 'Обьем двигателя',
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty
                      ? 'Пожалуйста, введите обьем двигателя'
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
                  keyboardType: TextInputType.number,
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
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите владелца' : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _osagoGivenDateController,
                  labelText: 'Дата выдачи ОСАГО',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату выдачи ОСАГО'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _osagoExpiryDateController,
                  labelText: 'Дата окончания ОСАГО',
                  firstDate: firstDate,
                  lastDate: lastDate,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату окончания ОСАГО'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _insuranceGivenDateRuController,
                  labelText: 'Дата выдачи страховки - Россия',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату выдачи страховки - Россия'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _insuranceExpiryDateRuController,
                  labelText: 'Дата окончания страховки - Россия',
                  firstDate: firstDate,
                  lastDate: lastDate,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату окончания страховки - Россия'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _insuranceGivenDateKzController,
                  labelText: 'Дата выдачи страховки - Казакстан',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату выдачи страховки - Казакстан'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _insuranceExpiryDateKzController,
                  labelText: 'Дата окончания страховки - Казакстан',
                  firstDate: firstDate,
                  lastDate: lastDate,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату окончания страховки - Казакстан'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _licenceGivenDateController,
                  labelText: 'Дата выдачи лицензии',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату выдачи лицензии'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _licenceExpiryDateController,
                  labelText: 'Дата окончания лицензии',
                  firstDate: firstDate,
                  lastDate: lastDate,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату окончания лицензии'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _inspectionGivenDateController,
                  labelText: 'Дата выдачи тех.осмотра',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату выдачи тех.осмотра'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _inspectionExpiryDateController,
                  labelText: 'Дата окончания тех.осмотра',
                  firstDate: firstDate,
                  lastDate: lastDate,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату окончания тех.осмотра'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _passGivenDateController,
                  labelText: 'Дата выдачи пропуска',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату выдачи пропуска'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _passExpiryDateController,
                  labelText: 'Дата окончания пропуска',
                  firstDate: firstDate,
                  lastDate: lastDate,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату окончания тпропуска'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _permitGivenDateController,
                  labelText: 'Дата выдачи дозвола',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату выдачи дозвола'
                      : null,
                ),
                AppConst.smallSpace,
                DatePickerWidget(
                  controller: _permitExpiryDateController,
                  labelText: 'Дата окончания дозвола',
                  firstDate: firstDate,
                  lastDate: lastDate,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Пожалуйста, введите дату окончания дозвола'
                      : null,
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
                AppConst.mediumSpace,
                _isLoadingVehicle
                    ? const Center(child: CircularProgressIndicator())
                    : CustomFilledButton(
                        onPressed: _addVehicle,
                        title: 'СОХРАНИТЬ',
                      ),
                AppConst.mediumSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
