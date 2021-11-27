class RegexPatterns {
  static const String emailPattern =
      r'^([a-z0-9_\.-]+\@[\da-z\.-]+\.[a-z\.]{2,6})$';

  static const String nameOrSurnamePattern =
      r"[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]";

  static const String nipNumberPattern = r'^\d{0,10}';
}
