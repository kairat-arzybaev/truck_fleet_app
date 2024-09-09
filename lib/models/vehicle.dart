class Vehicle {
  String maker;
  String model;
  String plateNumber;
  int mileage;
  String vin;

  Vehicle({
    required this.maker,
    required this.model,
    required this.plateNumber,
    required this.mileage,
    required this.vin,
  });

  Map<String, dynamic> toMap() {
    return {
      'maker': maker,
      'model': model,
      'plateNumber': plateNumber,
      'mileage': mileage,
      'vin': vin,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      maker: map['maker'],
      model: map['model'],
      plateNumber: map['plateNumber'],
      mileage: map['mileage'],
      vin: map['vin'],
    );
  }
}