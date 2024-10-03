import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String name;
  final String surname;
  final String? patronymic;
  final String idNumber;
  final String phoneNumber;
  final List<String>? imageUrls;

  Driver({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.surname,
    this.patronymic,
    required this.idNumber,
    required this.phoneNumber,
    this.imageUrls,
  });

  // Converts a Driver instance to a Map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'name': name,
      'surname': surname,
      'patronymic': patronymic,
      'idNumber': idNumber,
      'phoneNumber': phoneNumber,
      'imageUrls': imageUrls,
    };
  }

  // Creates a Driver instance from a Map retrieved from Firestore
  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as String,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
      name: map['name'] as String,
      surname: map['surname'] as String,
      patronymic: map['patronymic'] as String?,
      idNumber: map['idNumber'] as String,
      phoneNumber: map['phoneNumber'] as String,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }

  // Creates a copy of the current Driver with updated fields
  Driver copyWith({
    String? id,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? name,
    String? surname,
    String? patronymic,
    String? idNumber,
    String? phoneNumber,
    List<String>? imageUrls,
  }) {
    return Driver(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      patronymic: patronymic ?? this.patronymic,
      idNumber: idNumber ?? this.idNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Driver && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
