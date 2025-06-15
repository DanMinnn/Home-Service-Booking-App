class ServiceReq {
  final String name;
  final String des;
  final bool isActive;

  ServiceReq({
    required this.name,
    required this.des,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'des': des,
      'isActive': isActive,
    };
  }
}
