class Comment {
  double rating;
  String? comment;

  Comment({
    required this.rating,
    this.comment,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': this.rating,
      'comment': this.comment,
    };
  }

  @override
  String toString() {
    return 'Comment{rating: $rating, comment: $comment}';
  }
}
