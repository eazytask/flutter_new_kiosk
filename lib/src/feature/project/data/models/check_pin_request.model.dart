class CheckPinRequest {
  final int projectId;
  final int employeeId;
  final String pin;
  final String authToken;

  CheckPinRequest({
    required this.projectId,
    required this.employeeId,
    required this.pin,
    required this.authToken,
  });

  Map<String, dynamic> toMap() => {
    "project_id": projectId,
    "employee_id": employeeId,
    "pin": pin,
  };
}