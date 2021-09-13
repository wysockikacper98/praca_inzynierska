import 'package:flutter/material.dart';

class Address {
  String streetAndHouseNumber;
  String zipCode;
  String city;

  Address({
    @required this.streetAndHouseNumber,
    @required this.zipCode,
    @required this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      streetAndHouseNumber: json['streetAndHouseNumber'] ?? "",
      zipCode: json['zipCode'] ?? "",
      city: json['city'] ?? "",
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'streetAndHouseNumber': this.streetAndHouseNumber,
      'zipCode': this.zipCode,
      'city': this.city,
    };
  }

}

