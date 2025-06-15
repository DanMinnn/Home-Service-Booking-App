class PackageReq {
  final String packageName;
  final String packageDescription;
  final double packagePrice;

  PackageReq(
      {required this.packageName,
      required this.packageDescription,
      required this.packagePrice});

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'packageDescription': packageDescription,
      'packagePrice': packagePrice,
    };
  }
}
