double calculateRating(double rating, double ratingNumber) {
  const int PRECISION = 100;

  if (ratingNumber != 0.0) {
    return ((rating / ratingNumber) * PRECISION).round().toDouble() / PRECISION;
  } else
    return 0.0;
}
