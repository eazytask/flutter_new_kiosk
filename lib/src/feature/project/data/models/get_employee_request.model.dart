class GetEmployeeRequest {
  final String projectId;
  final String employeeFilter;
  final String authToken;

  GetEmployeeRequest({
    required this.projectId,
    required this.employeeFilter,
    required this.authToken,
  });
}
