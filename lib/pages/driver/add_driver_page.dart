import 'package:flutter/material.dart';
import 'package:truck_fleet_app/app_const.dart';
import '../../models/driver.dart';
import '../../services/firestore_services.dart';
import '../../widgets/custom_filled_button.dart';

class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key});

  @override
  State<AddDriverPage> createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _drivingLicenseNumberController = TextEditingController();
  final _expirationDateController = TextEditingController();
  DateTime? _birthDate;
  DateTime? _expirationDate;

  final FirestoreServices _firestoreServices = FirestoreServices();

  Future<void> _pickBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickExpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _saveDriver(Driver driver) {
    try {
      _firestoreServices.addDriver(driver);
      _clearForm();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Водитель добавлен успешно')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления водителя: $e')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _surnameController.clear();
    _ageController.clear();
    _addressController.clear();
    _phoneNumberController.clear();
    _idNumberController.clear();
    _drivingLicenseNumberController.clear();
    _expirationDateController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _idNumberController.dispose();
    _drivingLicenseNumberController.dispose();
    _expirationDateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить водителя'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Имя'),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите имя' : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Фамилия'),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите фамилию' : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: TextEditingController(
                    text: _birthDate != null
                        ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                        : '',
                  ),
                  decoration: const InputDecoration(labelText: 'Дата рождения'),
                  readOnly: true,
                  onTap: () => _pickBirthDate(context),
                  validator: (value) => _birthDate == null
                      ? 'Пожалуйста, выберите дату рождения'
                      : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Адрес'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите адрес' : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _phoneNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Номер телефона'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty
                      ? 'Пожалуйста, введите номер телефона'
                      : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _idNumberController,
                  decoration: const InputDecoration(labelText: 'Номер ID'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) =>
                      value!.isEmpty ? 'Пожалуйста, введите номер ID' : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: _drivingLicenseNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Номер водительского удостоверения'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) => value!.isEmpty
                      ? 'Пожалуйста, введите номер водительского удостоверения'
                      : null,
                ),
                AppConst.smallSpace,
                TextFormField(
                  controller: TextEditingController(
                    text: _expirationDate != null
                        ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                        : '',
                  ),
                  decoration: const InputDecoration(
                      labelText: 'Дата истечения срока действия'),
                  readOnly: true,
                  onTap: () => _pickExpDate(context),
                  validator: (value) => _expirationDate == null
                      ? 'Пожалуйста, выберите дату'
                      : null,
                ),
                AppConst.mediumSpace,
                CustomFilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Driver driver = Driver(
                        name: _nameController.text,
                        surname: _surnameController.text,
                        birthDate: DateTime.parse(_birthDate!.toString()),
                        address: _addressController.text,
                        phoneNumber: _phoneNumberController.text,
                        idNumber: _idNumberController.text,
                        drivingLicenseNumber:
                            _drivingLicenseNumberController.text,
                        expirationDate:
                            DateTime.parse(_expirationDate!.toString()),
                      );
                      _saveDriver(driver);
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
