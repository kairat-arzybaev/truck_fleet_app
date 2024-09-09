class Driver {
  String name;
  String surname;
    DateTime birthDate;

  String address;
  String phoneNumber;
  String idNumber;
  String drivingLicenseNumber;
  DateTime expirationDate;

  Driver({
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.address,
    required this.phoneNumber,
    required this.idNumber,
    required this.drivingLicenseNumber,
    required this.expirationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'birthDate': birthDate.toIso8601String(),
      'address': address,
      'phoneNumber': phoneNumber,
      'idNumber': idNumber,
      'drivingLicenseNumber': drivingLicenseNumber,
      'expirationDate': expirationDate.toIso8601String(),
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      name: map['name'],
      surname: map['surname'],
      birthDate: DateTime.parse(map['birthDate']),
      address: map['address'],
      phoneNumber: map['phoneNumber'],
      idNumber: map['idNumber'],
      drivingLicenseNumber: map['drivingLicenseNumber'],
      expirationDate: DateTime.parse(map['expirationDate']),
    );
  }
}