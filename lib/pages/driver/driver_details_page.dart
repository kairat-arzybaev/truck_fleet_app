import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truck_fleet_app/widgets/expandable_imagegrid.dart';
import '../../app_const.dart';
import '/widgets/confirmation_dialog.dart';
import '/models/driver.dart';
import '/services/firestore_services.dart';
import 'edit_driver_page.dart';

class DriverDetailsPage extends StatefulWidget {
  final Driver driver;

  const DriverDetailsPage({super.key, required this.driver});

  @override
  State<DriverDetailsPage> createState() => _DriverDetailsPageState();
}

class _DriverDetailsPageState extends State<DriverDetailsPage> {
  final FirestoreServices _firestoreServices = FirestoreServices();
  final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');

  late Driver _driver;

  @override
  void initState() {
    super.initState();
    _driver = widget.driver;
  }

  void _editDriver() async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDriverPage(driver: _driver),
      ),
    );
  }

  void _deleteDriver() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Удалить водителя',
        content: 'Вы уверены, что хотите удалить этого водителя?',
      ),
    ).then((value) => value ?? false);
    if (confirm) {
      try {
        await _firestoreServices.deleteDocumentWithImages(
          collectionName: 'drivers',
          documentId: _driver.id,
          imageUrls: _driver.imageUrls!,
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Водитель удален успешно.')),
        );
      } catch (e) {
        debugPrint('Error deleting driver: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при удалении водителя.')),
        );
      }
    }
  }

  Widget _buildDriverDetails(Driver driver) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (driver.patronymic != null && driver.patronymic!.isNotEmpty)
                  ? Text(
                      '${driver.surname} ${driver.name} ${driver.patronymic}',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  : Text(
                      '${driver.surname} ${driver.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
              _buildDetailRow('Номер ID', driver.idNumber),
              _buildDetailRow('Номер телефона', driver.phoneNumber),
              _buildDetailRow('Пол', driver.gender),
              _buildDetailRow('Дата рождения',
                  dateFormatter.format(driver.birthDate.toDate())),
              _buildDetailRow('Дата выдачи патента',
                  dateFormatter.format(driver.patentGivenDate.toDate())),
              _buildDetailRow('Дата окончания патента',
                  dateFormatter.format(driver.patentExpiryDate.toDate())),
            ],
          ),
        ),
        AppConst.mediumSpace,
        ExpandableImageGrid(imageUrls: driver.imageUrls!)
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          AppConst.smallSpace,
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали водителя'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editDriver,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteDriver,
          ),
        ],
      ),
      body: _buildDriverDetails(_driver),
    );
  }
}
