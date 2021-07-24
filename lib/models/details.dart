class Details {
  String description;
  List<dynamic> pictures;
  String prices;
  String calendar = "calendar";

  Details({
    this.description,
    this.pictures,
    this.prices,
    this.calendar,
  });

  @override
  String toString() {
    return '\nDescription:$description' +
        '\nPictures amount:${pictures.length}' +
        '\nCalendar:$calendar' +
        '\nPrices:\n$prices';
  }

  factory Details.fromJson(Map<String, dynamic> parsedJson) {
    return Details(
      description: parsedJson['description'],
      pictures: parsedJson['pictures'],
      calendar: parsedJson['calendar'],
      prices: parsedJson['prices'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': this.description,
      'pictures': this.pictures,
      'calendar': this.calendar,
      'prices': this.prices,
    };
  }
}
