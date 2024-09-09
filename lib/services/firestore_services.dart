import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/driver.dart';
import '../models/vehicle.dart';

class FirestoreServices {
  //  method for adding vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    await FirebaseFirestore.instance
        .collection('vehicles')
        .add(vehicle.toMap());
  }
  //  method for adding driver
  Future<void> addDriver(Driver driver) async {
    await FirebaseFirestore.instance.collection('drivers').add(driver.toMap());
  }

//  method for editing vehicle
  Future<void> updateVehicle(String vehicleId, Vehicle vehicle) async {
    await FirebaseFirestore.instance
        .collection('vehicles')
        .doc(vehicleId)
        .update(vehicle.toMap());
  }

//  method for deleting vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    await FirebaseFirestore.instance
        .collection('vehicles')
        .doc(vehicleId)
        .delete();
  }

//  method for editing driver
  Future<void> updateDriver(String driverId, Driver driver) async {
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .update(driver.toMap());
  }

//  method for deleting driver
  Future<void> deleteDriver(String driverId) async {
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .delete();
  }
//  method for getting documents of 'vehicle' collections 
  Stream<QuerySnapshot<Map<String, dynamic>>> getVehicles() {
    return FirebaseFirestore.instance.collection('vehicles').snapshots();
  }

//  method for getting documents of 'driver' collections 
  Stream<QuerySnapshot<Map<String, dynamic>>> getDrivers() {
    return FirebaseFirestore.instance.collection('drivers').snapshots();
  }
}
