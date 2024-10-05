import 'package:cloud_firestore/cloud_firestore.dart';

enum TrailerType {
  flatbed, // Бортовые
  enclosed, // Закрытые
  tarpaulin, // Тентованные
  specialized, // Специальные
  refrigerator, // Рефрижератор
}

const Map<TrailerType, String> trailerTypeDisplayNames = {
  TrailerType.flatbed: 'Бортовой',
  TrailerType.enclosed: 'Закрытый',
  TrailerType.tarpaulin: 'Полуприцеп тентованный',
  TrailerType.specialized: 'Специальный',
  TrailerType.refrigerator: 'Рефрижератор',
};

extension TrailerTypeExtension on TrailerType {
  String get displayName {
    return trailerTypeDisplayNames[this]!;
  }

  String get value {
    return toString().split('.').last;
  }

  static TrailerType fromValue(String value) {
    return TrailerType.values.firstWhere((e) => e.value == value);
  }
}

class Trailer {
  final String id;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String maker;
  final String model;
  final int yearManufactered;
  final String plateNumber;
  final String vin;
  final String color;

  final TrailerType type;
  final String subType;
  final int capacity;
  final List<String>? imageUrls;

  Trailer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.maker,
    required this.model,
    required this.yearManufactered,
    required this.plateNumber,
    required this.vin,
    required this.color,
    required this.type,
    required this.subType,
    required this.capacity,
    this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'maker': maker,
      'model': model,
      'yearManufactered': yearManufactered,
      'plateNumber': plateNumber,
      'vin': vin,
      'color': color,
      'type': type.value,
      'subType': subType,
      'capacity': capacity,
      'imageUrls': imageUrls,
    };
  }

  factory Trailer.fromMap(Map<String, dynamic> map) {
    return Trailer(
      id: map['id'],
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
      maker: map['maker'],
      model: map['model'],
      yearManufactered: map['yearManufactered'],
      plateNumber: map['plateNumber'],
      vin: map['vin'],
      color: map['color'],
      type: TrailerTypeExtension.fromValue(map['type']),
      subType: map['subType'],
      capacity: map['capacity'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }

  Trailer copyWith({
    String? id,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? maker,
    String? model,
    int? yearManufactered,
    String? plateNumber,
    String? vin,
    String? color,
    TrailerType? type,
    String? subType,
    int? capacity,
    List<String>? imageUrls,
  }) {
    return Trailer(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maker: maker ?? this.maker,
      model: model ?? this.model,
      yearManufactered: yearManufactered ?? this.yearManufactered,
      plateNumber: plateNumber ?? this.plateNumber,
      vin: vin ?? this.vin,
      color: color ?? this.color,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      capacity: capacity ?? this.capacity,
      imageUrls: imageUrls ?? imageUrls,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trailer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
