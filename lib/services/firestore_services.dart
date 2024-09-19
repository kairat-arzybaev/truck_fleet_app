import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/driver.dart';
import '../models/trailer.dart';
import '../models/vehicle.dart';

class FirestoreServices {
  // final CollectionReference _trailersCollection =
  //     FirebaseFirestore.instance.collection('trailers');
  final CollectionReference _driversCollection =
      FirebaseFirestore.instance.collection('drivers');
  final CollectionReference _vehiclesCollection =
      FirebaseFirestore.instance.collection('vehicles');

//------------TRAILER------------------------
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addTrailer(Trailer trailer) {
    return _db.collection('trailers').doc(trailer.id).set(trailer.toMap());
  }

  Future<List<Trailer>> fetchTrailers() async {
    QuerySnapshot snapshot = await _db.collection('trailers').get();
    return snapshot.docs.map((doc) {
      return Trailer.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Stream<List<Trailer>> getTrailers() {
    return _db
        .collection('trailers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trailer.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> updateTrailerImages(String trailerId, List<String> imageUrls) {
    return _db.collection('trailers').doc(trailerId).update({
      'registrationCertificateUrls': imageUrls,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> updateTrailer(Trailer trailer) {
    return _db.collection('trailers').doc(trailer.id).update(trailer.toMap());
  }

  Future<void> deleteTrailer(Trailer trailer) {
    return _db.collection('trailers').doc(trailer.id).delete();
  }

  Future<Trailer?> getTrailerById(String trailerId) async {
    DocumentSnapshot doc =
        await _db.collection('trailers').doc(trailerId).get();
    if (doc.exists) {
      return Trailer.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

//------------DRIVER------------------------
  Future<void> addDriver(Driver driver) =>
      _driversCollection.doc(driver.id).set(driver.toMap());

  Future<void> updateDriver(Driver driver) =>
      _driversCollection.doc(driver.id).update(driver.toMap());

  Future<void> deleteDriver(String driverId) =>
      _driversCollection.doc(driverId).delete();

  Stream<List<Driver>> getDrivers() {
    return _driversCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Driver.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

//------------VEHICLE------------------------
  Future<void> addVehicle(Vehicle vehicle) =>
      _vehiclesCollection.doc(vehicle.id).set(vehicle.toMap());

  Future<void> updateVehicle(Vehicle vehicle) =>
      _vehiclesCollection.doc(vehicle.id).update(vehicle.toMap());

  Future<void> deleteVehicle(String vehicleId) =>
      _vehiclesCollection.doc(vehicleId).delete();

  Stream<List<Vehicle>> getVehicles() {
    return _vehiclesCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Vehicle.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }
}
