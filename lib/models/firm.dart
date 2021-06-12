class Firm {
  String firmName;
  String name;
  String lastName;
  String phoneNumber;
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
    this.name,
    this.lastName,
    this.phoneNumber,
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
    return 'Firm:$firmName\nName:$name\nLastName:$lastName\nPhone:$phoneNumber\nEmail:$email\nLocation:$location\nRange$range\nNip$nip\nAvatar:$avatar\nRating:$rating\nCategory${category.toString()}';
  }

  factory Firm.fromJson(Map<String, dynamic> parsedJson) {
    return Firm(
      firmName: parsedJson['firmName'] ?? "",
      name: parsedJson['name'] ?? "",
      lastName: parsedJson['lastName'] ?? "",
      phoneNumber: parsedJson['phoneNumber'] ?? "",
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
      'name': this.name,
      'lastName': this.lastName,
      'phoneNumber': this.phoneNumber,
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
