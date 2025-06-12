class PaginationMetadata {
  final int pageNo;
  final int pageSize;
  final int totalPage;
  final int totalItems;

  PaginationMetadata({
    required this.pageNo,
    required this.pageSize,
    required this.totalPage,
    required this.totalItems,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      pageNo: json['pageNo'],
      pageSize: json['pageSize'],
      totalPage: json['totalPage'],
      totalItems: json['totalItems'] ?? (json['totalPage'] * json['pageSize']),
    );
  }
}
