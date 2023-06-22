import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/widgets/boards_list.dart';

class BoardsScreen extends StatefulWidget {
  const BoardsScreen({super.key, this.sprintId});

  final String? sprintId;

  @override
  State<StatefulWidget> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  final TasksRepository _tasksRepo = GetIt.instance();

  final List<Board> boards = List.empty();

  static Board _toDoBoard = Board("To do", List.empty());

  static Board _inProgressBoard = Board("In progress", List.empty());

  static Board _doneBoard = Board("Done", List.empty());

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: _tasksRepo.tasksStream(onlyCurrentUser: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          Iterable<Task> sprintData;
          if (widget.sprintId != null) {
            sprintData = snapshot.data
                    ?.where((element) => element.sprintId == widget.sprintId) ??
                List.empty();
          } else {
            sprintData = snapshot.data ?? List.empty();
          }

          _toDoBoard = Board(
              TaskState.toDo.text,
              sprintData
                  .where((element) => element.state == TaskState.toDo)
                  .toList());

          _inProgressBoard = Board(
              TaskState.inProgress.text,
              sprintData
                  .where((element) => element.state == TaskState.inProgress)
                  .toList());

          _doneBoard = Board(
              TaskState.done.text,
              sprintData
                  .where((element) => element.state == TaskState.done)
                  .toList());

          return BoardsList(boards: [_toDoBoard, _inProgressBoard, _doneBoard]);
        },
      );
}