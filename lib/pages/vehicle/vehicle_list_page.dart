import 'package:flutter/material.dart';
import '/services/firestore_services.dart';
import 'add_vehicle_page.dart';
import '/models/vehicle.dart';
import 'vehicle_details_page.dart';

class VehicleListPage extends StatelessWidget {
  VehicleListPage({super.key});

  final FirestoreServices _firestoreServices = FirestoreServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список фур'),
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: _firestoreServices.getVehicles(),
        builder: (context, snapshot) {
          return _buildVehicleList(context, snapshot);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Фура'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehiclePage()),
          );
        },
      ),
    );
  }

  Widget _buildVehicleList(
      BuildContext context, AsyncSnapshot<List<Vehicle>> snapshot) {
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

    final vehicles = snapshot.data;

    if (vehicles == null || vehicles.isEmpty) {
      return const Center(
        child: Text('Нет добавленных фур'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemCount: vehicles.length,
      itemBuilder: (context, index) =>
          _buildVehicleTile(context, vehicles[index]),
    );
  }

  Widget _buildVehicleTile(BuildContext context, Vehicle vehicle) {
    return ListTile(
      title: Text(vehicle.maker),
      subtitle: Text(vehicle.plateNumber),
      trailing: const Icon(Icons.chevron_right),
      tileColor: Colors.teal.shade500,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailsPage(vehicle: vehicle),
          ),
        );
      },
    );
  }
}
