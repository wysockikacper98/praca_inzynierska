class Details {
  String? description;
  List<dynamic>? pictures;
  String? prices;

  Details({
    this.description,
    this.pictures,
    this.prices,
  });

  @override
  String toString() {
    return '\nDescription:$description' +
        '\nPictures amount:${pictures!.length}' +
        '\nPrices:\n$prices';
  }

  factory Details.empty() {
    return Details(
      description: '',
      pictures: [],
      prices: '',
    );
  }

  factory Details.fromJson(Map<String, dynamic> parsedJson) {
    return Details(
      description: parsedJson['description'],
      pictures: parsedJson['pictures'],
      prices: parsedJson['prices'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': this.description,
      'pictures': this.pictures,
      'prices': this.prices,
    };
  }
}
