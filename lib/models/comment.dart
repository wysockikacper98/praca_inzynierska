class Comment {
  int rating;
  String? comment;
  DateTime dateTime;

  Comment({
    required this.rating,
    this.comment,
    required this.dateTime,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      rating: json['rating'].round() ?? 0,
      comment: json['comment'] ?? '',
      dateTime: json['dateTime'].toDate() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': this.rating,
      'comment': this.comment,
      'dateTime': this.dateTime,
    };
  }

  @override
  String toString() {
    return 'Comment{rating: $rating, comment: $comment, dateTime: $dateTime}';
  }
}
