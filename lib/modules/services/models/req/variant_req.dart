class Variant {
  final String variantName;
  final String variantDes;
  final double additionalPrice;

  Variant({
    required this.variantName,
    required this.variantDes,
    required this.additionalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'variantName': variantName,
      'variantDes': variantDes,
      'additionalPrice': additionalPrice,
    };
  }
}
