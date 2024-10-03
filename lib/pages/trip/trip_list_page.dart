import 'package:flutter/material.dart';

import 'add_trip_page.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список рейсов'),
      ),
      body: const Center(
        child: Text('Список рейсов'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Рейс'),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddTripPage()));
        },
      ),
    );
  }
}
