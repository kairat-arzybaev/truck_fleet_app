import 'package:flutter/material.dart';
import '../../app_const.dart';
import '/models/driver.dart';
import '/services/firestore_services.dart';
import 'add_driver_page.dart';
import 'driver_details_page.dart';

class DriverListPage extends StatelessWidget {
  DriverListPage({super.key});

  final FirestoreServices _firestoreServices = FirestoreServices();

  Widget _buildDriverList(List<Driver> drivers) {
    if (drivers.isEmpty) {
      return const Center(
        child: Text('Нет водителей'),
      );
    } else {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => AppConst.smallSpace,
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          final driver = drivers[index];
          return ListTile(
            title: Text('${driver.name} ${driver.surname}'),
            subtitle: Text('Телефон: ${driver.phoneNumber}'),
            trailing: const Icon(Icons.chevron_right),
            tileColor: Colors.blue.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverDetailsPage(driver: driver),
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
        title: const Text('Список водителей'),
      ),
      body: StreamBuilder<List<Driver>>(
        stream: _firestoreServices.getDrivers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Произошла ошибка при загрузке водителей.'),
            );
          } else if (snapshot.hasData) {
            return _buildDriverList(snapshot.data!);
          } else {
            return const Center(child: Text('Не удалось загрузить водителей'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDriverPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Водитель'),
      ),
    );
  }
}
