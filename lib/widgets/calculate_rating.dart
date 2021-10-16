double calculateRating(double rating, double ratingNumber) {
  if (ratingNumber != 0.0) {
    return (rating / ratingNumber);
  } else
    return 0.0;
}
