class ExecutionModel {
  final String id;
  final String status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? workflowName;
  final dynamic data;

  ExecutionModel({
    required this.id,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.workflowName,
    this.data,
  });
}
