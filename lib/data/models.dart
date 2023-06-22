import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/utils/extensions.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String? gitHubUser;
  final String? gitHubRepository;
  final String? gitHubToken;

  ProjectModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.gitHubUser,
      required this.gitHubRepository,
      required this.gitHubToken});

  factory ProjectModel.fromSnapshot(DocumentSnapshot doc) => ProjectModel(
      id: doc.id,
      name: doc.get('name'),
      description: doc.get('description'),
      gitHubUser: doc.getOrDefault('github_user', null),
      gitHubRepository: doc.getOrDefault('github_repository', null),
      gitHubToken: doc.getOrDefault('github_token', null));

  factory ProjectModel.fromDomain(Project project) => ProjectModel(
      id: project.id,
      name: project.name,
      description: project.description,
      gitHubUser: project.gitHubUser,
      gitHubRepository: project.gitHubRepository,
      gitHubToken: project.gitHubToken);

  Project toDomain() => Project(
      id: id,
      name: name,
      description: description,
      gitHubUser: gitHubUser,
      gitHubRepository: gitHubRepository,
      gitHubToken: gitHubToken);

  Map<String, dynamic> toMap() => <String, dynamic>{
        "name": name,
        "description": description,
        "github_user": gitHubUser,
        "github_repository": gitHubRepository,
        "github_token": gitHubToken
      };
}

class TaskModel {
  final String? id;
  final String? projectId;
  final String? ownerId;
  final String? sprintId;
  final String title;
  final String description;
  final String createdDate;
  final String? startedDate;
  final String? completedDate;
  final int state;
  final int priority;
  final int storyPoints;

  TaskModel(
      {required this.id,
      required this.projectId,
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

  factory TaskModel.fromSnapshot(DocumentSnapshot doc) => TaskModel(
      id: doc.id,
      projectId: doc.get('project_id'),
      ownerId: doc.get('owner_id'),
      sprintId: doc.get('sprint_id'),
      title: doc.get('title'),
      description: doc.get('description'),
      createdDate: doc.get('created_date'),
      startedDate: doc.getOrDefault('started_date', null),
      completedDate: doc.getOrDefault('completed_date', null),
      state: doc.get('state'),
      priority: doc.get('priority'),
      storyPoints: doc.get('story_points'));

  factory TaskModel.fromDomain(Task task, String projectId) => TaskModel(
      id: "",
      projectId: projectId,
      ownerId: task.ownerId,
      title: task.title,
      description: task.description,
      createdDate: task.createdDate,
      startedDate: task.startedDate,
      completedDate: task.completedDate,
      sprintId: task.sprintId,
      state: task.state.value,
      priority: task.priority.value,
      storyPoints: task.storyPoints);

  Task toDomain() => Task(
      id: id,
      ownerId: ownerId,
      sprintId: sprintId,
      title: title,
      description: description,
      createdDate: createdDate,
      startedDate: startedDate,
      completedDate: completedDate,
      state: TaskState.fromValue(state),
      priority: TaskPriority.fromValue(priority),
      storyPoints: storyPoints);

  Map<String, dynamic> toMap() => <String, dynamic>{
        "project_id": projectId,
        "owner_id": ownerId,
        "sprint_id": sprintId,
        "title": title,
        "description": description,
        "created_date": createdDate,
        "started_date": startedDate,
        "completed_date": completedDate,
        "state": state,
        "priority": priority,
        "story_points": storyPoints
      };
}

class SprintModel {
  final String id;
  final String? projectId;
  final String name;
  final String? startDate;
  final String? endDate;

  SprintModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory SprintModel.fromSnapshot(DocumentSnapshot doc) => SprintModel(
      id: doc.id,
      projectId: doc.getOrDefault("project_id", null),
      name: doc.get("name"),
      startDate: doc.getOrDefault("start_date", null),
      endDate: doc.getOrDefault("end_date", null));

  Sprint toDomain() =>
      Sprint(id: id, name: name, startDate: startDate, endDate: endDate);

  factory SprintModel.fromDomain(Sprint sprint, String projectId) =>
      SprintModel(
          id: sprint.id,
          projectId: projectId,
          name: sprint.name,
          startDate: sprint.startDate,
          endDate: sprint.endDate);

  Map<String, dynamic> toMap() => <String, dynamic>{
        "project_id": projectId,
        "name": name,
        "start_date": startDate,
        "end_date": endDate
      };
}

class UserModel {
  final String id;
  final String name;
  final String? gitHubUser;
  final List<dynamic> projectsIds;

  UserModel(
      {required this.id,
      required this.name,
      required this.gitHubUser,
      required this.projectsIds});

  factory UserModel.fromSnapshot(DocumentSnapshot doc) => UserModel(
      id: doc.id,
      name: doc.get("name"),
      gitHubUser: doc.getOrDefault('github_user', null),
      projectsIds: doc.getOrDefault('projects_ids', null) ?? List.empty());

  User toDomain() => User(id, name, gitHubUser, projectsIds.cast());
}