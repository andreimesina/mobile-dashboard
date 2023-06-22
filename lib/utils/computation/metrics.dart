import 'package:collection/collection.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/utils/extensions.dart';

extension TaskMetrics on Task {
  int? leadTime() {
    final created = createdDateObject();
    final completed = completedDateObject();

    if (created == null || completed == null) return null;

    return completed.difference(created).inDays;
  }

  int? cycleTime() {
    final started = startedDateObject();
    final completed = completedDateObject();

    if (started == null || completed == null) return null;

    return completed.difference(started).inDays;
  }

  int? queueTime() {
    final created = createdDateObject();
    final started = startedDateObject();

    if (created == null || started == null) return null;

    return started.difference(created).inDays;
  }

  double? timeInState() {
    final created = createdDateObject();
    final started = startedDateObject();
    final completed = completedDateObject();

    if (created == null || started == null || completed == null) return null;

    return (started.difference(created) + completed.difference(started))
            .inDays /
        2;
  }
}

double velocity(List<Task> tasks) => tasks.isEmpty
    ? 0
    : tasks
        .where((task) => task.state == TaskState.done)
        .map((task) => task.storyPoints)
        .sum
        .toDouble();

double averageLeadTime(List<Task> tasks) => tasks.isEmpty
    ? 0
    : tasks.map((task) => task.leadTime()).whereNotNull().average;

double averageCycleTime(List<Task> tasks) => tasks.isEmpty
    ? 0
    : tasks.map((task) => task.cycleTime()).whereNotNull().average;

double averageQueueTime(List<Task> tasks) => tasks.isEmpty
    ? 0
    : tasks.map((task) => task.queueTime()).whereNotNull().average;

double averageTimeInState(List<Task> tasks) => tasks.isEmpty
    ? 0
    : tasks.map((task) => task.timeInState()).whereNotNull().average;