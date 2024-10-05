import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truck_fleet_app/models/driver.dart';
import 'package:truck_fleet_app/models/trailer.dart';

class Vehicle {
  final String id;
  final String maker;
  final String model;
  final String plateNumber;
  final String yearManufactured;
  final double engineCapacity;
  final String color;
  final int mileage;
  final String vin;
  final Timestamp insuranceCertificateGivenDateRu;
  final Timestamp insuranceCertificateExpiryDateRu;
  final Timestamp insuranceCertificateGivenDateKz;
  final Timestamp insuranceCertificateExpiryDateKz;
  final Timestamp licenceGivenDate;
  final Timestamp licenceExpiryDate;
  final Timestamp inspectionGivenDate;
  final Timestamp inspectionExpiryDate;
  final Timestamp passGivenDate;
  final Timestamp passExpiryDate;
  final Timestamp permitGivenDate;
  final Timestamp permitExpiryDate;

  final Trailer trailer;
  final Driver driver;
  final String owner;
  final List<String> imageUrls;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Vehicle({
    required this.id,
    required this.maker,
    required this.model,
    required this.plateNumber,
    required this.yearManufactured,
    required this.engineCapacity,
    required this.color,
    required this.mileage,
    required this.vin,
    required this.insuranceCertificateGivenDateRu,
    required this.insuranceCertificateExpiryDateRu,
    required this.insuranceCertificateGivenDateKz,
    required this.insuranceCertificateExpiryDateKz,
    required this.licenceGivenDate,
    required this.licenceExpiryDate,
    required this.inspectionGivenDate,
    required this.inspectionExpiryDate,
    required this.passGivenDate,
    required this.passExpiryDate,
    required this.permitGivenDate,
    required this.permitExpiryDate,
    required this.trailer,
    required this.driver,
    required this.owner,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  // Converts the Vehicle instance to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maker': maker,
      'model': model,
      'plateNumber': plateNumber,
      'yearManufactured': yearManufactured,
      'engineCapacity': engineCapacity,
      'color': color,
      'mileage': mileage,
      'vin': vin,
      'insuranceCertificateGivenDateRu': insuranceCertificateGivenDateRu,
      'insuranceCertificateExpiryDateRu': insuranceCertificateExpiryDateRu,
      'insuranceCertificateGivenDateKz': insuranceCertificateGivenDateKz,
      'insuranceCertificateExpiryDateKz': insuranceCertificateExpiryDateKz,
      'licenceGivenDate': licenceGivenDate,
      'licenceExpiryDate': licenceExpiryDate,
      'inspectionGivenDate': inspectionGivenDate,
      'inspectionExpiryDate': inspectionExpiryDate,
      'passGivenDate': passGivenDate,
      'passExpiryDate': passExpiryDate,
      'permitGivenDate': permitGivenDate,
      'permitExpiryDate': permitExpiryDate,
      'trailer': trailer.toMap(),
      'driver': driver.toMap(),
      'owner': owner,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Creates a Vehicle instance from a Map<String, dynamic>
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      maker: map['maker'] as String,
      model: map['model'] as String,
      plateNumber: map['plateNumber'] as String,
      yearManufactured: map['yearManufactured'] as String,
      engineCapacity: map['engineCapacity'] is int
          ? (map['engineCapacity'] as int).toDouble()
          : map['engineCapacity'] as double,
      color: map['color'] as String,
      mileage: map['mileage'] as int,
      vin: map['vin'] as String,
      insuranceCertificateGivenDateRu:
          map['insuranceCertificateGivenDateRu'] as Timestamp,
      insuranceCertificateExpiryDateRu:
          map['insuranceCertificateExpiryDateRu'] as Timestamp,
      insuranceCertificateGivenDateKz:
          map['insuranceCertificateGivenDateKz'] as Timestamp,
      insuranceCertificateExpiryDateKz:
          map['insuranceCertificateExpiryDateKz'] as Timestamp,
      licenceGivenDate: map['licenceGivenDate'] as Timestamp,
      licenceExpiryDate: map['licenceExpiryDate'] as Timestamp,
      inspectionGivenDate: map['inspectionGivenDate'] as Timestamp,
      inspectionExpiryDate: map['inspectionExpiryDate'] as Timestamp,
      passGivenDate: map['passGivenDate'] as Timestamp,
      passExpiryDate: map['passExpiryDate'] as Timestamp,
      permitGivenDate: map['permitGivenDate'] as Timestamp,
      permitExpiryDate: map['permitExpiryDate'] as Timestamp,
      trailer: Trailer.fromMap(map['trailer'] as Map<String, dynamic>),
      driver: Driver.fromMap(map['driver'] as Map<String, dynamic>),
      owner: map['owner'] as String,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }

  // Creates a copy of the Vehicle with updated fields
  Vehicle copyWith({
    String? id,
    String? maker,
    String? model,
    String? plateNumber,
    String? yearManufactured,
    double? engineCapacity,
    String? color,
    int? mileage,
    String? vin,
    Timestamp? insuranceCertificateGivenDateRu,
    Timestamp? insuranceCertificateExpiryDateRu,
    String? insuranceCertificateNumberKz,
    Timestamp? insuranceCertificateGivenDateKz,
    Timestamp? insuranceCertificateExpiryDateKz,
    Timestamp? licenceGivenDate,
    Timestamp? licenceExpiryDate,
    Timestamp? inspectionGivenDate,
    Timestamp? inspectionExpiryDate,
    Timestamp? passGivenDate,
    Timestamp? passExpiryDate,
    Timestamp? permitGivenDate,
    Timestamp? permitExpiryDate,
    Trailer? trailer,
    Driver? driver,
    String? owner,
    List<String>? imageUrls,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      maker: maker ?? this.maker,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      yearManufactured: yearManufactured ?? this.yearManufactured,
      engineCapacity: engineCapacity ?? this.engineCapacity,
      color: color ?? this.color,
      mileage: mileage ?? this.mileage,
      vin: vin ?? this.vin,
      insuranceCertificateGivenDateRu: insuranceCertificateGivenDateRu ??
          this.insuranceCertificateGivenDateRu,
      insuranceCertificateExpiryDateRu: insuranceCertificateExpiryDateRu ??
          this.insuranceCertificateExpiryDateRu,
      insuranceCertificateGivenDateKz: insuranceCertificateGivenDateKz ??
          this.insuranceCertificateGivenDateKz,
      insuranceCertificateExpiryDateKz: insuranceCertificateExpiryDateKz ??
          this.insuranceCertificateExpiryDateKz,
      licenceGivenDate: licenceGivenDate ?? this.licenceGivenDate,
      licenceExpiryDate: licenceExpiryDate ?? this.licenceExpiryDate,
      inspectionGivenDate: inspectionGivenDate ?? this.inspectionGivenDate,
      inspectionExpiryDate: inspectionExpiryDate ?? this.inspectionExpiryDate,
      passGivenDate: passGivenDate ?? this.passGivenDate,
      passExpiryDate: passExpiryDate ?? this.passExpiryDate,
      permitGivenDate: permitGivenDate ?? this.permitGivenDate,
      permitExpiryDate: permitExpiryDate ?? this.permitExpiryDate,
      trailer: trailer ?? this.trailer,
      driver: driver ?? this.driver,
      owner: owner ?? this.owner,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
