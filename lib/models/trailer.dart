import 'package:cloud_firestore/cloud_firestore.dart';

enum TrailerType {
  flatbed, // Бортовые
  enclosed, // Закрытые
  tarpaulin, // Тентованные
  specialized, // Специальные
}

const Map<TrailerType, String> trailerTypeDisplayNames = {
  TrailerType.flatbed: 'Бортовой',
  TrailerType.enclosed: 'Закрытый',
  TrailerType.tarpaulin: 'Тентованный',
  TrailerType.specialized: 'Специальный',
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final String maker;
  final String model;
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
    required this.plateNumber,
    required this.vin,
    required this.type,
    this.registrationCertificateUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'maker': maker,
      'model': model,
      'plateNumber': plateNumber,
      'vin': vin,
      'type': type.value,
      'registrationCertificateUrls': registrationCertificateUrls,
    };
  }

  factory Trailer.fromMap(Map<String, dynamic> map) {
    return Trailer(
      id: map['id'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      maker: map['maker'],
      model: map['model'],
      plateNumber: map['plateNumber'],
      vin: map['vin'],
      type: TrailerTypeExtension.fromValue(map['type']),
      registrationCertificateUrls:
          List<String>.from(map['registrationCertificateUrls'] ?? []),
    );
  }

  Trailer copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? maker,
    String? model,
    String? plateNumber,
    String? vin,
    TrailerType? type,
    List<String>? registrationCertificateUrl,
  }) {
    return Trailer(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maker: maker ?? this.maker,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      vin: vin ?? this.vin,
      type: type ?? this.type,
      registrationCertificateUrls:
          registrationCertificateUrls ?? registrationCertificateUrls,
    );
  }
}
