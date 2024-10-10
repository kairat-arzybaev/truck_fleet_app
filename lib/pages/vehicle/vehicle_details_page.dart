import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:truck_fleet_app/models/vehicle.dart';
import 'package:truck_fleet_app/widgets/expandable_imagegrid.dart';
import 'package:truck_fleet_app/models/trailer.dart';
import 'package:truck_fleet_app/models/driver.dart';

import '../../app_const.dart';
import '../../services/firestore_services.dart';
import '../../widgets/confirmation_dialog.dart';
import 'edit_vehicle_page.dart';

class VehicleDetailsPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final FirestoreServices _firestoreServices = FirestoreServices();

  void _deleteVehicle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Удалить фуру',
        content: 'Вы уверены, что хотите удалить эту фуру?',
      ),
    ).then((value) => value ?? false);

    if (confirm) {
      try {
        await _firestoreServices.deleteDocumentWithImages(
          collectionName: 'vehicles',
          documentId: widget.vehicle.id,
          imageUrls: widget.vehicle.imageUrls,
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фура удалена успешно.')),
        );
      } catch (e) {
        debugPrint('Error deleting vehicle: $e');
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при удалении фуры.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.vehicle.imageUrls;
    final DateFormat dateFormatter = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали фуры'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditVehiclePage(vehicle: widget.vehicle)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteVehicle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          //
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Basic Information
              _buildDetailRow('Марка', widget.vehicle.maker),
              _buildDetailRow('Модель', widget.vehicle.model),
              _buildDetailRow('Гос.номер', widget.vehicle.plateNumber),
              _buildDetailRow('Год выпуска', widget.vehicle.yearManufactured),
              _buildDetailRow(
                  'Объем двигателя', widget.vehicle.engineCapacity.toString()),
              _buildDetailRow('Цвет', widget.vehicle.color),
              _buildDetailRow('Пробег', widget.vehicle.mileage.toString()),
              _buildDetailRow('VIN', widget.vehicle.vin),
              _buildDetailRow('Владелец', widget.vehicle.owner),
              _buildDetailRow(
                'Дата выдачи ОСАГО',
                dateFormatter.format(widget.vehicle.osagoGivenDate.toDate()),
              ),
              _buildDetailRow(
                'Дата окончания ОСАГО',
                dateFormatter.format(widget.vehicle.osagoExpiryDate.toDate()),
              ),
              _buildDetailRow(
                'Дата выдачи страховки-RU',
                dateFormatter.format(
                    widget.vehicle.insuranceCertificateGivenDateRu.toDate()),
              ),
              _buildDetailRow(
                'Дата окончания страховки-RU',
                dateFormatter.format(
                    widget.vehicle.insuranceCertificateExpiryDateRu.toDate()),
              ),

              _buildDetailRow(
                'Дата выдачи страховки-KZ',
                dateFormatter.format(
                    widget.vehicle.insuranceCertificateGivenDateKz.toDate()),
              ),
              _buildDetailRow(
                'Дата окончания страховки-KZ',
                dateFormatter.format(
                    widget.vehicle.insuranceCertificateExpiryDateKz.toDate()),
              ),
              _buildDetailRow(
                'Дата выдачи лицензии',
                dateFormatter.format(widget.vehicle.licenceGivenDate.toDate()),
              ),
              _buildDetailRow(
                'Дата окончания лицензии',
                dateFormatter.format(widget.vehicle.licenceExpiryDate.toDate()),
              ),
              _buildDetailRow(
                'Дата выдачи тех.осмотра',
                dateFormatter
                    .format(widget.vehicle.inspectionGivenDate.toDate()),
              ),
              _buildDetailRow(
                'Дата окончания тех.осмотра',
                dateFormatter
                    .format(widget.vehicle.inspectionExpiryDate.toDate()),
              ),
              _buildDetailRow(
                'Дата выдачи пропуска',
                dateFormatter.format(widget.vehicle.passGivenDate.toDate()),
              ),
              _buildDetailRow(
                'Дата окончания пропуска',
                dateFormatter.format(widget.vehicle.passExpiryDate.toDate()),
              ),
              _buildDetailRow(
                'Дата выдачи дозвола',
                dateFormatter.format(widget.vehicle.permitGivenDate.toDate()),
              ),
              _buildDetailRow(
                'Дата окончания дозвола',
                dateFormatter.format(widget.vehicle.permitExpiryDate.toDate()),
              ),

              // Trailer Information
              AppConst.mediumSpace,
              const Text(
                'Прицеп',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              _buildTrailerInfo(widget.vehicle.trailer),

              // Driver Information
              AppConst.mediumSpace,
              const Text(
                'Водитель',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              _buildDriverInfo(widget.vehicle.driver),
              AppConst.mediumSpace,
              ExpandableImageGrid(imageUrls: imageUrls)
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a row for each detail
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

  // Display trailer information
  Widget _buildTrailerInfo(Trailer trailer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Марка прицепа', trailer.maker),
        _buildDetailRow('Модель прицепа', trailer.model),
        _buildDetailRow('Гос.номер прицепа', trailer.plateNumber),
      ],
    );
  }

  // Display driver information
  Widget _buildDriverInfo(Driver driver) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('ФИО водителя', '${driver.name} ${driver.surname}'),
        _buildDetailRow('Телефон водителя', driver.phoneNumber),
      ],
    );
  }
}
