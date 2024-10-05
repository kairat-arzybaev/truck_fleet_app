import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/driver.dart';
import '../models/trailer.dart';
import '../models/vehicle.dart';

class FirestoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

//------------TRAILER------------------------

  Future<void> addTrailer(Trailer trailer) {
    return _db.collection('trailers').doc(trailer.id).set(trailer.toMap());
  }

  Future<void> updateTrailer(Trailer trailer) {
    return _db.collection('trailers').doc(trailer.id).update(trailer.toMap());
  }

  Future<void> deleteTrailer(Trailer trailer) {
    return _db.collection('trailers').doc(trailer.id).delete();
  }

  Stream<List<Trailer>> getTrailers() {
    return _db.collection('trailers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trailer.fromMap(doc.data());
      }).toList();
    });
  }

  Future<List<Trailer>> getTrailersOnce() async {
    final snapshot = await _db.collection('trailers').get();
    return snapshot.docs
        .map((doc) => Trailer.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  Future<void> updateTrailerImages(String trailerId, List<String> imageUrls) {
    return _db.collection('trailers').doc(trailerId).update({
      'imageUrls': imageUrls,
      'updatedAt': DateTime.now(),
    });
  }

//------------DRIVER------------------------
  Future<void> addDriver(Driver driver) =>
      _db.collection('drivers').doc(driver.id).set(driver.toMap());

  Future<void> updateDriver(Driver driver) =>
      _db.collection('drivers').doc(driver.id).update(driver.toMap());

  Future<void> deleteDriver(String driverId) =>
      _db.collection('drivers').doc(driverId).delete();

  Stream<List<Driver>> getDrivers()  {
     return _db
        .collection('drivers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Driver.fromMap(doc.data());
            }).toList());
  }

  Future<List<Driver>> getDriversOnce() async {
    final snapshot = await _db.collection('drivers').get();
    return snapshot.docs
        .map((doc) => Driver.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  Future<void> updateDriverImages(String driverId, List<String> imageUrls) {
    return _db.collection('drivers').doc(driverId).update({
      'imageUrls': imageUrls,
      'updatedAt': DateTime.now(),
    });
  }

//--------------VEHICLE----------------------------

  Future<void> addVehicle(Vehicle vehicle) =>
      _db.collection('vehicles').doc(vehicle.id).set(vehicle.toMap());

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _db.collection('vehicles').doc(vehicle.id).update(vehicle.toMap());
  }

  Stream<List<Vehicle>> getVehicles() {
    return _db
        .collection('vehicles')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Vehicle.fromMap(doc.data());
            }).toList());
  }

  Future<void> updateVehicleImages(String vehicleId, List<String> imageUrls) {
    return _db.collection('vehicles').doc(vehicleId).update({
      'imageUrls': imageUrls,
      'updatedAt': DateTime.now(),
    });
  }

//---------DELETE DOCUMENT WITH IMAGES--------------
  Future<void> deleteDocumentWithImages({
    required String collectionName,
    required String documentId,
    required List<String> imageUrls,
  }) async {
    try {
      // Delete images from Firebase Storage in parallel
      List<Future<void>> deleteFutures = imageUrls.map((imageUrl) async {
        try {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        } catch (e) {
          debugPrint('Error $imageUrl: $e');
          // Handle specific exceptions if necessary
        }
      }).toList();

      await Future.wait(deleteFutures);

      // Delete the document from Firestore
      await _db.collection(collectionName).doc(documentId).delete();
    } catch (e) {
      debugPrint('Error deleting document and images: $e');
      rethrow; // Rethrow to be handled by the calling function
    }
  }
}
