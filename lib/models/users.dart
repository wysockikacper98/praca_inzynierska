class Users {
  final String email;
  final String firstName;
  final String lastName;
  final String rating;
  final String telephone;
  final String avatar;

  Users({
    this.email,
    this.firstName,
    this.lastName,
    this.rating,
    this.telephone,
    this.avatar,
  });

  factory Users.fromJson(Map<String, dynamic> parsedJson) {
    return Users(
      firstName: parsedJson['firstName'] ?? "",
      lastName: parsedJson['lastName'] ?? "",
      email: parsedJson['email'] ?? "",
      rating: parsedJson['rating']?? "",
      avatar: parsedJson['avatar'] ?? "",
      telephone: parsedJson['telephone'] ?? "",
    );
  }

  @override
  String toString() {
    return "FirstName:" + this.firstName +
        "\nLastName:" + this.lastName +
        "\nEmail:" + this.email +
        "\nRating:" + this.rating +
        "\nTelephone:" + this.telephone +
        "\nAvatar:" + this.avatar;
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': this.firstName,
      'lastName': this.lastName,
      'email': this.email,
      'rating': this.rating,
      'avatar': this.avatar,
      'telephone': this.telephone,
    };
  }
}
