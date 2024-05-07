class StartUnscheduledShiftRequest {
  final int? employeeId;
  final String? latitude;
  final String? longitude;
  final String? projectId;
  final String? jobTypeId;
  final String authToken;
  final String ratePerHour;
  final String? remarks;
  final String? image;
  final String? comment;

  StartUnscheduledShiftRequest({
    required this.employeeId,
    required this.longitude,
    required this.latitude,
    required this.authToken,
    required this.projectId,
    required this.jobTypeId,
    required this.remarks,
    required this.ratePerHour,
    required this.image,
    required this.comment,
  });

  Map<String, dynamic> toMap() => {
    "lat": '',
    "lon": '',
    "ratePerHour" : ratePerHour,
    "employee_id": employeeId.toString(),
    "project_id": projectId,
    "job_type_id": jobTypeId,
    "remarks": remarks,
    "image": image,
    "comment": comment,
  };
}