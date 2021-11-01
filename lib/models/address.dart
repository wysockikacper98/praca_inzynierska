class Address {
  String streetAndHouseNumber;
  String zipCode;
  String city;
  String? subAdministrativeArea;
  String? administrativeArea;

  Address({
    required this.streetAndHouseNumber,
    required this.zipCode,
    required this.city,
    this.subAdministrativeArea,
    this.administrativeArea,
  });

  factory Address.empty() {
    return Address(
      streetAndHouseNumber: '',
      zipCode: '',
      city: '',
      subAdministrativeArea: '',
      administrativeArea: '',
    );
  }

  @override
  String toString() {
    return '''Address:\n
streetAndHouseNumber: $streetAndHouseNumber
zipCode: $zipCode
city: $city
subAdministrativeArea: $subAdministrativeArea
administrativeArea: $administrativeArea
''';
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      streetAndHouseNumber: json['streetAndHouseNumber'] ?? "",
      zipCode: json['zipCode'] ?? "",
      city: json['city'] ?? "",
      subAdministrativeArea: json['subAdministrativeArea'],
      administrativeArea: json['administrativeArea'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streetAndHouseNumber': this.streetAndHouseNumber,
      'zipCode': this.zipCode,
      'city': this.city,
      'subAdministrativeArea': this.subAdministrativeArea,
      'administrativeArea': this.administrativeArea,
    };
  }
}
