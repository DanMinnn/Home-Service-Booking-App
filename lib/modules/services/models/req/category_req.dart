class CategoryReq {
  final String categoryName;
  final bool isActive;

  CategoryReq({
    required this.categoryName,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'isActive': isActive,
    };
  }
}
