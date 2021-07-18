import 'package:flutter/cupertino.dart';
import 'package:praca_inzynierska/models/details.dart';
import 'package:praca_inzynierska/models/users.dart';

class Firm {
  String firmName;
  String firstName;
  String lastName;
  String telephone;
  String email;
  String location;
  String range;
  String nip;
  String avatar;
  String rating;
  List<String> category;
  UserType type;
  Details details;

  Firm({
    @required this.firmName,
    this.firstName,
    this.lastName,
    this.telephone,
    this.email,
    this.location,
    this.range,
    @required this.nip,
    this.category,
    this.avatar,
    this.rating,
    @required this.type,
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
        '\nCategory:${category.toString()}' +
        '\nType:' +
        (this.type == UserType.Firm ? "Firm" : "Private User") +
        '\nDetails:${details.toString()}';
  }

  factory Firm.fromJson(Map<String, dynamic> parsedJson) {

    print(parsedJson['firmName']);
    print(parsedJson['firstName']);
    print(parsedJson['lastName']);
    print(parsedJson['telephone']);
    print(parsedJson['email']);
    print(parsedJson['location']);
    print(parsedJson['range']);
    print(parsedJson['nip']);
    print(parsedJson['avatar']);
    print(parsedJson['rating']);
    print(parsedJson['category']);
    print(parsedJson['type']);



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
      category: parsedJson['category'] ?? [],
      type: parsedJson['type'] == 'Firm' ? UserType.Firm : UserType.PrivateUser,
      details: Details.fromJson(parsedJson['details']) ?? "",
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
      'category': this.category,
      'type': this.type.toString().split('.').last,
      'details': this.details.toJson(),
    };
  }
}


class FirmProvider with ChangeNotifier{
  Firm _firm;

  Firm get firm {
    return _firm;
  }

  set firm(Firm value){
    print("Firm Updated");
    _firm = value;
    notifyListeners();
  }

  void updateFirm(Firm updatedFirm){
    _firm = updatedFirm;
    notifyListeners();
  }

  void clearFirmInfo(){
    _firm = null;
    notifyListeners();
  }

}
