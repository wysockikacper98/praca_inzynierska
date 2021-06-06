class Firm {
  final String category;
  final String email;
  final String firstName;
  final String secondName;
  final String location;
  final String phoneNumber;
  final String rating;
  final String avatar;

  Firm({
    this.category,
    this.email,
    this.firstName,
    this.secondName,
    this.location,
    this.phoneNumber,
    this.rating,
    this.avatar,
  });

  @override
  String toString() {
    return 'Firm{category: $category, email: $email, firstName: $firstName, secondName: $secondName, location: $location, phoneNumber: $phoneNumber, rating: $rating, avatar: $avatar}';
  }
}
