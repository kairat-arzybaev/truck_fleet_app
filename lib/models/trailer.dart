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
  final TrailerType type;
  final List<String>? registrationCertificateUrls;

  Trailer({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.maker,
    required this.model,
    required this.yearManufactered,
    required this.plateNumber,
    required this.vin,
    required this.type,
    this.registrationCertificateUrls,
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
      'type': type.value,
      'registrationCertificateUrls': registrationCertificateUrls,
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
      type: TrailerTypeExtension.fromValue(map['type']),
      registrationCertificateUrls:
          List<String>.from(map['registrationCertificateUrls'] ?? []),
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
    TrailerType? type,
    List<String>? registrationCertificateUrls,
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
      type: type ?? this.type,
      registrationCertificateUrls:
          registrationCertificateUrls ?? registrationCertificateUrls,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trailer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
