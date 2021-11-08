import 'package:flutter/foundation.dart';

enum UserType {
  Firm,
  PrivateUser,
}

class Users {
  final String email;
  final String firstName;
  final String lastName;
  final double? rating;
  final double? ratingNumber;
  final String? telephone;
  final String? avatar;
  final UserType type;

  final List<String>? tokens;

  Users({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.rating,
    this.ratingNumber,
    this.telephone,
    this.avatar,
    required this.type,
    this.tokens,
  });

  factory Users.empty() {
    return Users(
      email: '',
      firstName: '',
      lastName: '',
      rating: 0.0,
      ratingNumber: 0.0,
      telephone: '',
      avatar: '',
      type: UserType.PrivateUser,
    );
  }

  factory Users.fromJson(Map<String, dynamic> parsedJson) {
    return Users(
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      email: parsedJson['email'] ?? '',
      rating: parsedJson['rating'] ?? 0.0,
      ratingNumber: parsedJson['ratingNumber'] ?? 0.0,
      avatar: parsedJson['avatar'] ?? '',
      telephone: parsedJson['telephone'] ?? '',
      type: parsedJson['type'] == 'PrivateUser'
          ? UserType.PrivateUser
          : UserType.Firm,
      tokens: parsedJson['tokens'] != null
          ? parsedJson['tokens'].cast<String>()
          : [],
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
        this.rating.toString() +
        "\nRating Number:" +
        this.ratingNumber.toString() +
        "\nTelephone:" +
        this.telephone! +
        "\nAvatar:" +
        this.avatar! +
        "\nType:" +
        (this.type == UserType.Firm ? 'Firm' : 'Private User') +
        "\nTokens:" +
        (this.tokens != null ? 'exist' : 'does not exist');
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
      'tokens': this.tokens,
    };
  }
}

class UserProvider with ChangeNotifier {
  Users? _user;

  Users? get user {
    return _user;
  }

  set user(Users? value) {
    print("User Updated");
    _user = value;
    notifyListeners();
  }

  void updateUser(Users updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void clearUserInfo() {
    _user = Users.empty();
    notifyListeners();
  }
}
