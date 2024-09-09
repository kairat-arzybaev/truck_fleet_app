import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_services.dart';
import 'add_vehicle_page.dart';
import '../../models/vehicle.dart';

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  final FirestoreServices _firestoreServices = FirestoreServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список фур'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreServices.getVehicles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ошибка при загрузке данных'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final vehicleDocs = snapshot.data!.docs;

          if (vehicleDocs.isEmpty) {
            return const Center(
              child: Text('Нет добавленных фур'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemCount: vehicleDocs.length,
            itemBuilder: (context, index) {
              var vehicleData =
                  vehicleDocs[index].data() as Map<String, dynamic>;
              Vehicle vehicle = Vehicle.fromMap(vehicleData);

              return ListTile(
                title: Text('${vehicle.maker} ${vehicle.model}'),
                subtitle: Text('${vehicle.mileage} км\n${vehicle.plateNumber}'),
                trailing: const Icon(Icons.more_vert),
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Фура'),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddVehiclePage()));
        },
      ),
    );
  }
}
