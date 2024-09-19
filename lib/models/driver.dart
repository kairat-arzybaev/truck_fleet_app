import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String name;
  final String surname;
  final DateTime birthDate;
  final String address;
  final String phoneNumber;
  final String idNumber;
  final String drivingLicenseNumber;
  final DateTime expirationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Driver({
    required this.id,
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.address,
    required this.phoneNumber,
    required this.idNumber,
    required this.drivingLicenseNumber,
    required this.expirationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'surname': surname,
      'birthDate': birthDate.millisecondsSinceEpoch,
      'address': address,
      'phoneNumber': phoneNumber,
      'idNumber': idNumber,
      'drivingLicenseNumber': drivingLicenseNumber,
      'expirationDate': expirationDate.millisecondsSinceEpoch,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as String,
      name: map['name'] as String,
      surname: map['surname'] as String,
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birthDate'] as int),
      address: map['address'] as String,
      phoneNumber: map['phoneNumber'] as String,
      idNumber: map['idNumber'] as String,
      drivingLicenseNumber: map['drivingLicenseNumber'] as String,
      expirationDate:
          DateTime.fromMillisecondsSinceEpoch(map['expirationDate'] as int),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
