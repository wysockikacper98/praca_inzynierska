import 'package:flutter/foundation.dart';

enum UserType {
  Firm,
  PrivateUser,
}

class Users {
  final String email;
  final String firstName;
  final String lastName;
  final String rating;
  final String ratingNumber;
  final String telephone;
  final String avatar;
  final UserType type;

  Users({
    @required this.email,
    this.firstName,
    this.lastName,
    this.rating,
    this.ratingNumber,
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
      ratingNumber: parsedJson['ratingNumber'] ?? '0',
      avatar: parsedJson['avatar'] ?? '',
      telephone: parsedJson['telephone'] ?? '',
      type: parsedJson['type'] == 'PrivateUser'
          ? UserType.PrivateUser
          : UserType.Firm,
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
        "\nRating Number:" +
        this.ratingNumber +
        "\nTelephone:" +
        this.telephone +
        "\nAvatar:" +
        this.avatar +
        "\nType:" +
        (this.type == UserType.Firm ? 'Firm' : 'Private User');
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': this.firstName,
      'lastName': this.lastName,
      'email': this.email,
      'rating': this.rating,
      'ratingNumber': this.ratingNumber,
      'avatar': this.avatar,
      'telephone': this.telephone,
      'type': this.type.toString().split('.').last,
    };
  }
}

class UserProvider with ChangeNotifier {
  Users _user;

  Users get user {
    return _user;
  }

  set user(Users value) {
    print("User Updated");
    _user = value;
    notifyListeners();
  }

  void updateUser(Users updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void clearUserInfo() {
    _user = null;
    notifyListeners();
  }
}
