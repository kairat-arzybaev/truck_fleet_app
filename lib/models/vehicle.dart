import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  String id;
  String maker;
  String model;
  String plateNumber;
  int mileage;
  String vin;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.maker,
    required this.model,
    required this.plateNumber,
    required this.mileage,
    required this.vin,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maker': maker,
      'model': model,
      'plateNumber': plateNumber,
      'mileage': mileage,
      'vin': vin,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      maker: map['maker'],
      model: map['model'],
      plateNumber: map['plateNumber'],
      mileage: map['mileage'],
      vin: map['vin'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
