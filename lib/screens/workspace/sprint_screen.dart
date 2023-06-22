import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/workspace/create_edit_task_screen.dart';
import 'package:mobile_dashboard/utils/computation/sprints.dart';
import 'package:mobile_dashboard/widgets/boards_list.dart';

class SprintScreen extends StatefulWidget {
  const SprintScreen({super.key, required this.sprint});

  final Sprint sprint;

  @override
  State<SprintScreen> createState() => _SprintScreenState();
}

class _SprintScreenState extends State<SprintScreen> {
  final TasksRepository _tasksRepo = GetIt.instance();

  static Board _toDoBoard = Board(TaskState.toDo.text, List.empty());

  static Board _inProgressBoard =
      Board(TaskState.inProgress.text, List.empty());

  static Board _doneBoard = Board(TaskState.done.text, List.empty());

  late double _completion;
  late int _storyPoints;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.sprint.name)),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEditTaskScreen(),
                ));
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 6),
              child: Row(children: [
                const Text("Start date",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(
                  width: 8,
                ),
                Text(widget.sprint.startDate ?? "Not set")
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Row(
                children: [
                  const Text("End date",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(widget.sprint.endDate ?? "Not set")
                ],
              ),
            ),
            StreamBuilder(
                stream: _tasksRepo.tasksStream(),
                builder: (context, snapshot) {
                  final sprintTasks = snapshot.data?.where(
                          (element) => element.sprintId == widget.sprint.id) ??
                      List.empty();

                  _storyPoints = sprintTasks.sprintTotalPoints();

                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6),
                    child: Row(
                      children: [
                        const Text("Total story points",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(_storyPoints.toString())
                      ],
                    ),
                  );
                }),
            StreamBuilder(
                stream: _tasksRepo.tasksStream(),
                builder: (context, snapshot) {
                  final sprintTasks = snapshot.data?.where(
                          (element) => element.sprintId == widget.sprint.id) ??
                      List.empty();

                  _completion = sprintTasks.sprintCompletion();

                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 6),
                    child: Row(
                      children: [
                        const Text("Completion",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(
                          width: 8,
                        ),
                        Text("$_completion%")
                      ],
                    ),
                  );
                }),
            StreamBuilder(
              stream: _tasksRepo.tasksStream(onlyCurrentUser: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                Iterable<Task> sprintData = snapshot.data?.where(
                        (element) => element.sprintId == widget.sprint.id) ??
                    List.empty();

                _toDoBoard = Board(
                    TaskState.toDo.text,
                    sprintData
                        .where((element) => element.state == TaskState.toDo)
                        .toList());

                _inProgressBoard = Board(
                    TaskState.inProgress.text,
                    sprintData
                        .where(
                            (element) => element.state == TaskState.inProgress)
                        .toList());

                _doneBoard = Board(
                    TaskState.done.text,
                    sprintData
                        .where((element) => element.state == TaskState.done)
                        .toList());

                return Expanded(
                    child: BoardsList(
                        boards: [_toDoBoard, _inProgressBoard, _doneBoard]));
              },
            )
          ],
        ),
      );
}