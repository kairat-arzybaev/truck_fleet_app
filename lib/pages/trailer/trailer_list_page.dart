import 'package:flutter/material.dart';
import 'package:truck_fleet_app/app_const.dart';
import '/models/trailer.dart';
import '/services/firestore_services.dart';
import 'add_trailer_page.dart';
import 'trailer_details_page.dart';

class TrailerListPage extends StatelessWidget {
  TrailerListPage({super.key});

  final FirestoreServices _firestoreServices = FirestoreServices();

  Widget _buildTrailerList(List<Trailer> trailers) {
    if (trailers.isEmpty) {
      return const Center(
        child: Text('Нет прицепов'),
      );
    } else {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => AppConst.smallSpace,
        itemCount: trailers.length,
        itemBuilder: (context, index) {
          final trailer = trailers[index];
          return ListTile(
            title: Text('${trailer.maker} ${trailer.model}'),
            subtitle: Text('Гос. номер: ${trailer.plateNumber}'),
            trailing: const Icon(Icons.chevron_right),
            tileColor: Colors.deepOrange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrailerDetailsPage(trailer: trailer),
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список прицепов'),
      ),
      body: StreamBuilder<List<Trailer>>(
        stream: _firestoreServices.getTrailers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return const Center(
              child: Text('Произошла ошибка при загрузке прицепов.'),
            );
          } else if (snapshot.hasData) {
            return _buildTrailerList(snapshot.data!);
          } else {
            return const Center(child: Text('Не удалось загрузить прицепы'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTrailerPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Прицеп'),
      ),
    );
  }
}
