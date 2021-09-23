import 'package:flutter/material.dart';

import 'details.dart';
import 'users.dart';

class Firm {
  String firmName;
  String firstName;
  String lastName;
  String? telephone;
  String email;
  String? location;
  String? range;
  String nip;
  String? avatar;
  String? rating;
  String? ratingNumber;
  List<dynamic>? category;
  UserType type;
  Details? details;

  Firm({
    required this.firmName,
    required this.firstName,
    required this.lastName,
    this.telephone,
    required this.email,
    this.location,
    this.range,
    required this.nip,
    this.category,
    this.avatar,
    this.rating,
    this.ratingNumber,
    required this.type,
    this.details,
  });

  @override
  String toString() {
    return 'Firm:$firmName' +
        '\nName:$firstName' +
        '\nLastName:$lastName' +
        '\nPhone:$telephone' +
        '\nEmail:$email' +
        '\nLocation:$location' +
        '\nRange$range' +
        '\nNip$nip' +
        '\nAvatar:$avatar' +
        '\nRating:$rating' +
        '\nRating Number:$ratingNumber' +
        '\nCategory:${category.toString()}' +
        '\nType:' +
        (this.type == UserType.Firm ? "Firm" : "Private User") +
        '\nDetails:${details.toString()}';
  }

  factory Firm.fromJson(Map<String, dynamic> parsedJson) {
    return Firm(
      firmName: parsedJson['firmName'] ?? "",
      firstName: parsedJson['firstName'] ?? "",
      lastName: parsedJson['lastName'] ?? "",
      telephone: parsedJson['telephone'] ?? "",
      email: parsedJson['email'] ?? "",
      location: parsedJson['location'] ?? "",
      range: parsedJson['range'] ?? "",
      nip: parsedJson['nip'] ?? "",
      avatar: parsedJson['avatar'] ?? "",
      rating: parsedJson['rating'] ?? "",
      ratingNumber: parsedJson['ratingNumber'] ?? "",
      category: parsedJson['category'] ?? [],
      type: parsedJson['type'] == 'Firm' ? UserType.Firm : UserType.PrivateUser,
      details: Details.fromJson(parsedJson['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firmName': this.firmName,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'telephone': this.telephone,
      'email': this.email,
      'location': this.location,
      'range': this.range,
      'nip': this.nip,
      'avatar': this.avatar,
      'rating': this.rating,
      'ratingNumber': this.ratingNumber,
      'category': this.category,
      'type': this.type.toString().split('.').last,
      'details': this.details!.toJson(),
    };
  }
}

class FirmProvider with ChangeNotifier {
  Firm? _firm;

  Firm get firm {
    return _firm!;
  }

  set firm(Firm value) {
    print("Firm Updated");
    _firm = value;
    notifyListeners();
  }

  void updateFirm(Firm updatedFirm) {
    _firm = updatedFirm;
    notifyListeners();
  }

  void clearFirmInfo() {
    _firm = null;
    notifyListeners();
  }
}
