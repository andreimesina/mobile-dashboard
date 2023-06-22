import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_dashboard/data/repository/firebase_repository.dart';
import 'package:mobile_dashboard/data/models.dart';
import 'package:mobile_dashboard/domain/models.dart';

class UsersRepository extends FirestoreRepository {
  final users = ValueNotifier<List<User>>(List.empty());

  UsersRepository() {
    getUsers();
  }

  void getUsers() {
    firestore
        .collection("users")
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs
            .map((doc) => UserModel.fromSnapshot(doc).toDomain())
            .toList())
        .listen((event) {
      users.value = event;
    }, onError: (error, message) {
      print("error users: $error $message");
    });
  }
}