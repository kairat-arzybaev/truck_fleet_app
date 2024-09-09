import 'package:flutter/material.dart';
import 'package:truck_fleet_app/app_const.dart';
import 'package:truck_fleet_app/services/firestore_services.dart';
import '../../models/vehicle.dart';
import '../../widgets/custom_filled_button.dart';

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
  final _mileageController = TextEditingController();
  final _vinController = TextEditingController();

  final FirestoreServices _firestoreServices = FirestoreServices();

  void _saveVehicle(Vehicle vehicle) {
    try {
      _firestoreServices.addVehicle(vehicle);
      _clearForm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фура успешно добавлено')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _clearForm() {
    _makerController.clear();
    _modelController.clear();
    _plateNumberController.clear();
    _mileageController.clear();
    _vinController.clear();
  }

  @override
  void dispose() {
    _makerController.dispose();
    _modelController.dispose();
    _plateNumberController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                TextFormField(
                  controller: _makerController,
                  decoration: const InputDecoration(labelText: 'Марка'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите марку' : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Модель'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите модель' : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _plateNumberController,
                  decoration: const InputDecoration(labelText: 'Номерной знак'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) => value!.isEmpty
                      ? 'Пожалуйста, введите номерной знак'
                      : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(labelText: 'Пробег'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите пробег' : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _vinController,
                  decoration: const InputDecoration(labelText: 'VIN'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите VIN' : null,
                ),
                AppConst.mediumSpace,
                CustomFilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Vehicle vehicle = Vehicle(
                        maker: _makerController.text,
                        model: _modelController.text,
                        plateNumber: _plateNumberController.text,
                        mileage: int.parse(_mileageController.text),
                        vin: _vinController.text,
                      );
                      _saveVehicle(vehicle);
                    }
                  },
                  title: 'СОХРАНИТЬ',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
