import 'package:flutter/material.dart';
import 'package:truck_fleet_app/app_const.dart';
import 'package:truck_fleet_app/widgets/expandable_imagegrid.dart';
import '/widgets/confirmation_dialog.dart';
import '/models/trailer.dart';
import 'edit_trailer_page.dart';
import '/services/firestore_services.dart';

class TrailerDetailsPage extends StatefulWidget {
  final Trailer trailer;

  const TrailerDetailsPage({super.key, required this.trailer});

  @override
  State<TrailerDetailsPage> createState() => _TrailerDetailsPageState();
}

class _TrailerDetailsPageState extends State<TrailerDetailsPage> {
  final FirestoreServices _firestoreServices = FirestoreServices();
  late Trailer _trailer;

  @override
  void initState() {
    super.initState();
    _trailer = widget.trailer;
  }

  void _editTrailer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTrailerPage(trailer: _trailer),
      ),
    );
  }

  void _deleteTrailer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Удалить прицеп',
        content: 'Вы уверены, что хотите удалить этот прицеп?',
      ),
    ).then((value) => value ?? false);
    if (confirm) {
      try {
        await _firestoreServices.deleteDocumentWithImages(
          collectionName: 'trailers',
          documentId: _trailer.id,
          imageUrls: _trailer.registrationCertificateUrls!,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Прицеп и связанные изображения удалены.')),
        );
        Navigator.pop(context);
      } catch (e) {
        debugPrint('Error deleting trailer and images: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ошибка при удалении прицепа или изображений.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали прицепа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTrailer,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTrailer,
          ),
        ],
      ),
      body: _buildTrailerDetails(_trailer),
    );
  }

  Widget _buildTrailerDetails(Trailer trailer) {
    final imageUrls = trailer.registrationCertificateUrls ?? [];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${trailer.maker} ${trailer.model}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Гос. Номер: ${trailer.plateNumber}'),
              Text('VIN: ${trailer.vin}'),
              Text('Тип: ${trailer.type.displayName}'),
              Text('Год выпуска: ${trailer.yearManufactered}'),
            ],
          ),
        ),
        AppConst.mediumSpace,
        ExpandableImageGrid(imageUrls: imageUrls)
      ],
    );
  }
}
