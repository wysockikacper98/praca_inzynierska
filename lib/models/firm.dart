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

  // final String category;
  // final String email;
  // final String firstName;
  // final String secondName;
  // final String location;
  // final String phoneNumber;
  // final String rating;
  // final String avatar;

  Firm({
    this.firmName,
    this.firstName,
    this.lastName,
    this.telephone,
    this.email,
    this.location,
    this.range,
    this.nip,
    this.category,
    this.avatar,
    this.rating,
  });

  @override
  String toString() {
    return 'Firm:$firmName\nName:$firstName\nLastName:$lastName\nPhone:$telephone\nEmail:$email\nLocation:$location\nRange$range\nNip$nip\nAvatar:$avatar\nRating:$rating\nCategory${category.toString()}';
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
      category: parsedJson['category'] ?? [],
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
    };
  }
}
