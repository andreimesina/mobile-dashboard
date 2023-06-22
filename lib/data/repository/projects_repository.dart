import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_dashboard/data/github_api.dart';
import 'package:mobile_dashboard/data/repository/firebase_repository.dart';
import 'package:mobile_dashboard/data/models.dart';
import 'package:mobile_dashboard/domain/models.dart';

class ProjectsRepository extends FirestoreRepository {
  final ValueNotifier<Project?> selectedProject = ValueNotifier(null);

  Stream<List<Project>> getProjects() => firestore
      .collection('projects')
      .snapshots()
      .map((QuerySnapshot snapshot) => snapshot.docs
          .map((doc) => ProjectModel.fromSnapshot(doc).toDomain())
          .toList());

  void updateProject(Project project) {
    firestore
        .collection('projects')
        .doc(project.id)
        .update(ProjectModel.fromDomain(project).toMap())
        .onError((error, stackTrace) => print("Error updating project: $error"))
        .then((value) {
      if (project.id == selectedProject.value?.id) {
        selectProject(project);
      }
    });
  }

  void selectProject(Project project) {
    selectedProject.value = project;
  }
}