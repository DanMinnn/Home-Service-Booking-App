class Tasker {
  int id;
  String fullName;
  String phoneNumber;
  String email;
  String? profileImage;
  TaskerReviewResponse? review;

  Tasker(this.id, this.fullName, this.phoneNumber, this.email,
      this.profileImage, this.review);

  factory Tasker.fromJson(Map<String, dynamic> json) {
    return Tasker(
      json['id'] as int,
      json['fullName'] as String,
      json['phoneNumber'] as String,
      json['email'] as String,
      json['profileImage'] as String?,
      json['taskerReviewResponse'] != null
          ? TaskerReviewResponse.fromJson(
              json['taskerReviewResponse'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TaskerReviewResponse {
  int id;
  double reputationScore;
  int totalReviews;

  TaskerReviewResponse(this.id, this.reputationScore, this.totalReviews);

  factory TaskerReviewResponse.fromJson(Map<String, dynamic> json) {
    return TaskerReviewResponse(
      json['taskerId'] as int,
      (json['reputationScore'] as num).toDouble(),
      json['totalReviews'] as int,
    );
  }
}
