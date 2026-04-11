class ExecutionModel {
  final String id;
  final String? workflowId;
  final String? workflowName;
  final String status;
  final String? startedAt;
  final String? stoppedAt;
  final int? executionTime;
  final Map<String, dynamic>? data;
  final bool? finished;
  final String? mode;

  ExecutionModel({
    required this.id,
    this.workflowId,
    this.workflowName,
    required this.status,
    this.startedAt,
    this.stoppedAt,
    this.executionTime,
    this.data,
    this.finished,
    this.mode,
  });

  factory ExecutionModel.fromJson(Map<String, dynamic> json) {
    final workflowData = json['workflowData'] as Map<String, dynamic>?;
    return ExecutionModel(
      id: json['id'].toString(),
      workflowId: json['workflowId']?.toString(),
      workflowName: workflowData?['name'] as String? ?? json['workflowName'] as String?,
      status: json['status'] as String? ?? 'unknown',
      startedAt: json['startedAt'] as String?,
      stoppedAt: json['stoppedAt'] as String?,
      executionTime: json['executionTime'] as int?,
      data: json['data'] as Map<String, dynamic>?,
      finished: json['finished'] as bool?,
      mode: json['mode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workflowId': workflowId,
        'workflowName': workflowName,
        'status': status,
        'startedAt': startedAt,
        'stoppedAt': stoppedAt,
        'executionTime': executionTime,
        'data': data,
        'finished': finished,
        'mode': mode,
      };

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';
  bool get isRunning => status == 'running';
}

class ExecutionNodeData {
  final String nodeName;
  final String? status;
  final dynamic inputData;
  final dynamic outputData;
  final String? error;
  final int? executionTime;

  ExecutionNodeData({
    required this.nodeName,
    this.status,
    this.inputData,
    this.outputData,
    this.error,
    this.executionTime,
  });

  factory ExecutionNodeData.fromJson(String name, Map<String, dynamic> json) {
    return ExecutionNodeData(
      nodeName: name,
      status: json['executionStatus'] as String?,
      inputData: json['inputOverride'],
      outputData: json['data'],
      error: json['error']?.toString(),
      executionTime: json['executionTime'] as int?,
    );
  }
}
