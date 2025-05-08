class PageResponse {
  int pageNo;
  int pageSize;
  int totalPage;
  int items;

  PageResponse({
    required this.pageNo,
    required this.pageSize,
    required this.totalPage,
    required this.items,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json) {
    return PageResponse(
      pageNo: json['page_no'] ?? 0,
      pageSize: json['page_size'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      items: json['items'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page_no': pageNo,
      'page_size': pageSize,
      'total_page': totalPage,
      'items': items,
    };
  }
}
