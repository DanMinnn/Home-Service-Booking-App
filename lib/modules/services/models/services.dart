class ServiceCategoryResponse {
  final int status;
  final String message;
  final ServiceCategoryData data;

  ServiceCategoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ServiceCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryResponse(
      status: json['status'],
      message: json['message'],
      data: ServiceCategoryData.fromJson(json['data']),
    );
  }
}

class ServiceCategoryData {
  final int pageNo;
  final int pageSize;
  final int totalPage;
  final List<ServiceCategory> items;

  ServiceCategoryData({
    required this.pageNo,
    required this.pageSize,
    required this.totalPage,
    required this.items,
  });

  factory ServiceCategoryData.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryData(
      pageNo: json['pageNo'],
      pageSize: json['pageSize'],
      totalPage: json['totalPage'],
      items: (json['items'] as List)
          .map((item) => ServiceCategory.fromJson(item))
          .toList(),
    );
  }
}

class ServiceCategory {
  final int id;
  final String name;
  final List<Service> services;
  final bool active;
  final bool isDeleted;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.services,
    required this.active,
    this.isDeleted = false,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      services: (json['services'] as List)
          .map((service) => Service.fromJson(service))
          .toList(),
      active: json['active'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

class Service {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;
  final bool isDeleted;

  Service({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.isActive,
    this.isDeleted = false,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: json['isActive'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

class ServiceDetailResponse {
  final int status;
  final String message;
  final ServiceDetail data;

  ServiceDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ServiceDetailResponse.fromJson(Map<String, dynamic> json) {
    return ServiceDetailResponse(
      status: json['status'],
      message: json['message'],
      data: ServiceDetail.fromJson(json['data']),
    );
  }
}

class ServiceDetail {
  final int id;
  final String name;
  List<ServicePackage> servicePackages;
  final bool active;
  final bool isDeleted;

  ServiceDetail({
    required this.id,
    required this.name,
    required this.servicePackages,
    required this.active,
    this.isDeleted = false,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      servicePackages: json['servicePackages'] != null
          ? (json['servicePackages'] as List)
              .map((package) => ServicePackage.fromJson(package))
              .toList()
          : [],
      active: json['active'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

class ServicePackage {
  final int id;
  final String name;
  final String description;
  final double basePrice;
  List<PackageVariant> variants;
  final bool isDeleted;

  ServicePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.variants,
    this.isDeleted = false,
  });

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    return ServicePackage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: json['basePrice'] ?? 0.0,
      isDeleted: json['isDeleted'] ?? false,
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((variant) => PackageVariant.fromJson(variant))
              .toList()
          : [],
    );
  }
}

class PackageVariant {
  final int id;
  final String name;
  final String? description;
  final double? additionalPrice;
  final bool isDeleted;

  PackageVariant({
    required this.id,
    required this.name,
    this.description,
    this.additionalPrice,
    this.isDeleted = false,
  });

  factory PackageVariant.fromJson(Map<String, dynamic> json) {
    return PackageVariant(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      additionalPrice: json['additionalPrice'] ?? 0.0,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
