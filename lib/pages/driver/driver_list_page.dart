import 'package:flutter/material.dart';

import '/models/driver.dart';
import '/services/firestore_services.dart';
import 'add_driver_page.dart';

class DriverListPage extends StatefulWidget {
  const DriverListPage({super.key});

  @override
  State<DriverListPage> createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
  final FirestoreServices _firestoreServices = FirestoreServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список водителей'),
      ),
      body: StreamBuilder<List<Driver>>(
        stream: _firestoreServices.getDrivers(),
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

          final drivers = snapshot.data!;

          if (drivers.isEmpty) {
            return const Center(
              child: Text('Нет добавленных фур'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemCount: drivers.length,
            itemBuilder: (context, index) => _buildDriverTile(drivers[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Водитeль'),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddDriverPage()));
        },
      ),
    );
  }

  Widget _buildDriverTile(Driver driver) {
    return ListTile(
      title: Text('${driver.name} ${driver.surname}'),
      subtitle: Text(driver.address),
      trailing: const Icon(Icons.more_vert),
      onTap: () {},
    );
  }
}
