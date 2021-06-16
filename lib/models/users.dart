import 'package:flutter/cupertino.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';

class Users {
  final String email;
  final String firstName;
  final String lastName;
  final String rating;
  final String telephone;
  final String avatar;
  final UserType type;

  Users({
    @required this.email,
    this.firstName,
    this.lastName,
    this.rating,
    this.telephone,
    this.avatar,
    @required this.type,
  });

  factory Users.fromJson(Map<String, dynamic> parsedJson) {
    return Users(
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      email: parsedJson['email'] ?? '',
      rating: parsedJson['rating'] ?? '0',
      avatar: parsedJson['avatar'] ?? '',
      telephone: parsedJson['telephone'] ?? '',
      type: parsedJson['type'] == 'PrivateUser' ? UserType.PrivateUser : null,
    );
  }

  @override
  String toString() {
    return "FirstName:" +
        this.firstName +
        "\nLastName:" +
        this.lastName +
        "\nEmail:" +
        this.email +
        "\nRating:" +
        this.rating +
        "\nTelephone:" +
        this.telephone +
        "\nAvatar:" +
        this.avatar +
        "\nType:" +
        (this.type == UserType.Firm ? "Firm" : "Private User");
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': this.firstName,
      'lastName': this.lastName,
      'email': this.email,
      'rating': this.rating,
      'avatar': this.avatar,
      'telephone': this.telephone,
      'type': UserType.PrivateUser.toString().split('.').last,
    };
  }
}
