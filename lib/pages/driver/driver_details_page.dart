import 'package:flutter/material.dart';
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
  late Driver _driver;

  @override
  void initState() {
    super.initState();
    _driver = widget.driver;
  }

  void _editDriver() async {
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Водитель удален успешно.')),
        );
        Navigator.pop(context);
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
    final imageUrls = driver.imageUrls ?? [];
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${driver.name} ${driver.surname}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (driver.patronymic != null && driver.patronymic!.isNotEmpty)
                Text('Отчество: ${driver.patronymic}'),
              Text('Телефон: ${driver.phoneNumber}'),
            ],
          ),
        ),
        AppConst.mediumSpace,
        ExpandableImageGrid(imageUrls: imageUrls)
      ],
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
