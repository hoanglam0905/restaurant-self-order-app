class AttendanceResponse {
  final String message;
  final double? workingHours;
  final double? totalWorkingHours;

  AttendanceResponse({
    required this.message,
    this.workingHours,
    this.totalWorkingHours,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      message: json['message'] ?? '',
      workingHours: (json['working_hours'] as num?)?.toDouble(),
      totalWorkingHours: (json['total_working_hours'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'working_hours': workingHours,
      'total_working_hours': totalWorkingHours,
    };
  }
}
