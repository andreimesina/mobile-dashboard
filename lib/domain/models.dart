import 'package:mobile_dashboard/utils/pair.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String? gitHubUser;
  final String? gitHubRepository;
  final String? gitHubToken;

  Project(
      {required this.id,
      required this.name,
      required this.description,
      required this.gitHubUser,
      required this.gitHubRepository,
      required this.gitHubToken});
}

class Task {
  final String? id;
  final String? ownerId;
  final String? sprintId;
  final String title;
  final String description;
  final String createdDate;
  final String? startedDate;
  final String? completedDate;
  final TaskState state;
  final TaskPriority priority;
  final int storyPoints;

  Task(
      {required this.id,
      required this.ownerId,
      required this.sprintId,
      required this.title,
      required this.description,
      required this.createdDate,
      required this.startedDate,
      required this.completedDate,
      required this.state,
      required this.priority,
      required this.storyPoints});

  @override
  String toString() {
    return 'Task{id: $id, ownerId: $ownerId, sprintId: $sprintId, title: $title, description: $description, createdDate: $createdDate, startedDate: $startedDate, completedDate: $completedDate, state: $state, priority: $priority, storyPoints: $storyPoints}';
  }
}

enum TaskState {
  toDo(1, "To do"),
  inProgress(2, "In progress"),
  done(3, "Done");

  final int value;
  final String text;

  const TaskState(this.value, this.text);

  static TaskState fromValue(int value) =>
      TaskState.values.firstWhere((element) => element.value == value);
}

enum TaskPriority {
  low(1, "Low"),
  medium(2, "Medium"),
  high(3, "High");

  final int value;
  final String text;

  const TaskPriority(this.value, this.text);

  static TaskPriority fromValue(int value) =>
      TaskPriority.values.firstWhere((element) => element.value == value);
}

class Sprint {
  final String id;
  final String name;
  final String? startDate;
  final String? endDate;

  Sprint(
      {required this.id,
      required this.name,
      required this.startDate,
      required this.endDate});

  Sprint.unassigned()
      : this(id: "-1", name: "No sprint", startDate: null, endDate: null);
}

class Board {
  final String name;
  final List<Task> tasks;

  Board(this.name, this.tasks);
}

class User {
  final String id;
  final String name;
  final String? githubUser;
  final List<String> projectsIds;

  User(this.id, this.name, this.githubUser, this.projectsIds);

  User.unassigned() : this("-1", "Unassigned", null, List.empty());
}

class Metric {
  final String name;
  final String description;
  final String measureUnit;

  Metric(
      {required this.name,
      required this.description,
      required this.measureUnit});
}

class PredefinedMetric extends Metric {
  final Function(List<Task>) formula;

  PredefinedMetric(
      {required name,
      required description,
      required measureUnit,
      required this.formula})
      : super(name: name, description: description, measureUnit: measureUnit);
}

class MetricValuesForSprints {
  final PredefinedMetric metric;
  final List<SprintMetricValue> sprintMetricPairs;

  MetricValuesForSprints(
      {required this.metric, required this.sprintMetricPairs});
}

class SprintMetricValue {
  final Sprint sprint;
  final double value;

  SprintMetricValue(this.sprint, this.value);
}

class DynamicMetric extends Metric {
  DynamicMetric(
      {required super.name,
      required super.description,
      required super.measureUnit});
}

class DynamicMetricValues {
  final DynamicMetric metric;
  final List<StringNumValue> values;

  DynamicMetricValues({required this.metric, required this.values});
}

class StringNumValue {
  final String name;
  final num value;

  StringNumValue(this.name, this.value);
}