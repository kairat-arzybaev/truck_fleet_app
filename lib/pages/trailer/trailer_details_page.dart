import 'package:flutter/material.dart';
import '/models/trailer.dart';
import 'document_images_page.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            '${trailer.maker} ${trailer.model}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Номерной знак: ${trailer.plateNumber}'),
          Text('VIN: ${trailer.vin}'),
          Text('Тип: ${trailer.type.toString().split('.').last}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showDocumentImages(trailer),
            child: const Text('Просмотреть документы'),
          ),
        ],
      ),
    );
  }

  void _showDocumentImages(Trailer trailer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumentImagesPage(imageUrls: trailer.registrationCertificateUrls!),
      ),
    );
  }

  void _editTrailer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTrailerPage(trailer: _trailer),
      ),
    );
    // Optionally refresh data if the trailer was edited
  }

  void _deleteTrailer() async {
    final confirm = await _showDeleteConfirmationDialog();
    if (confirm) {
      await _firestoreServices.deleteTrailer(_trailer);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Прицеп удален.')),
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить прицеп'),
          content: const Text('Вы уверены, что хотите удалить этот прицеп?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ОТМЕНА'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('УДАЛИТЬ'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
