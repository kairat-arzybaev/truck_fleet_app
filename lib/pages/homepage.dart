import 'package:flutter/material.dart';
import 'package:truck_fleet_app/pages/driver/driver_list_page.dart';

import 'vehicle/vehicle_list_page.dart';
import 'trailer/trailer_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        child: NavigationBar(
            selectedIndex: currentPageIndex,
            destinations: const [
              // NavigationDestination(
              //     icon: Icon(Icons.analytics_outlined),
              //     selectedIcon: Icon(Icons.analytics),
              //     label: 'Дашборд'),
              // NavigationDestination(
              //     icon: Icon(Icons.route_outlined),
              //     selectedIcon: Icon(Icons.route),
              //     label: 'Рейсы'),
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: 'Фуры',
              ),
              NavigationDestination(
                  icon: Icon(Icons.person_outlined),
                  selectedIcon: Icon(Icons.person),
                  label: 'Водители'),
              NavigationDestination(
                  icon: Icon(Icons.train_outlined),
                  selectedIcon: Icon(Icons.train),
                  label: 'Прицепы'),
            ],
            onDestinationSelected: (index) {
              setState(() {
                currentPageIndex = index;
              });
            }),
      ),
      body: [
        // const DashboardPage(),
        // const TripListPage(),
        VehicleListPage(),
        DriverListPage(),
        TrailerListPage(),
      ][currentPageIndex],
    );
  }
}
