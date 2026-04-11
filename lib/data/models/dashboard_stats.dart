class DashboardStats {
  final int totalWorkflows;
  final int activeWorkflows;
  final int failedExecutions;
  final int totalExecutionsToday;
  final List<dynamic> recentExecutions;

  DashboardStats({
    this.totalWorkflows = 0,
    this.activeWorkflows = 0,
    this.failedExecutions = 0,
    this.totalExecutionsToday = 0,
    this.recentExecutions = const [],
  });
}
