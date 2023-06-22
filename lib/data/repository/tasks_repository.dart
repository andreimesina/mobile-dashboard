import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_dashboard/data/repository/firebase_repository.dart';
import 'package:mobile_dashboard/data/models.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/utils/computation/sorting.dart';
import 'package:mobile_dashboard/utils/extensions.dart';

class TasksRepository extends FirestoreRepository {
  ValueNotifier<Project?> selectedProject;
  final ValueNotifier<List<Sprint>> sprints = ValueNotifier(List.empty());

  TasksRepository(this.selectedProject) {
    fetchSprints();

    selectedProject.addListener(() {
      sprints.value = List.empty();
      fetchSprints();
    });
  }

  Stream<List<Task>> tasksStream({bool onlyCurrentUser = false}) =>
      firestore
        .collection('tasks')
        .where("project_id", isEqualTo: selectedProject.value?.id)
        .whereCurrentUser(onlyCurrentUser)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs
          .map((doc) => TaskModel.fromSnapshot(doc).toDomain())
          .toList()
          .sortedByPriority());

  void updateTask(Task task) {
    final taskProjectId = selectedProject.value?.id;
    if (taskProjectId == null) return;

    firestore
        .collection("tasks")
        .doc(task.id)
        .update(TaskModel.fromDomain(task, taskProjectId).toMap())
        .onError((error, stackTrace) => print("Error updating task: $error"));
  }

  void addTask(Task task) {
    final taskProjectId = selectedProject.value?.id;
    if (taskProjectId == null) return;

    firestore
        .collection("tasks")
        .add(TaskModel.fromDomain(task, taskProjectId).toMap());
  }

  void fetchSprints() {
    firestore
        .collection("sprints")
        .where("project_id", isEqualTo: selectedProject.value?.id)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs
            .map((doc) => SprintModel.fromSnapshot(doc).toDomain())
            .toList())
        .listen((event) {
      event.sortedByEndDate();
      sprints.value = event;
    });
  }

  void addSprint(Sprint sprint) {
    final projectId = selectedProject.value?.id;
    if (projectId == null) return;

    firestore
        .collection("sprints")
        .add(SprintModel.fromDomain(sprint, projectId).toMap());
  }
}