import 'package:flutter/material.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/workspace/create_edit_task_screen.dart';
import 'package:mobile_dashboard/widgets/search_field.dart';
import 'package:mobile_dashboard/widgets/tasks_list.dart';

class TasksScreen extends StatelessWidget {
  final List<Task>? tasks;
  final Board? board;
  final bool showTitle;

  const TasksScreen(
      {super.key, this.tasks, this.board, required this.showTitle});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: showTitle
          ? AppBar(
              title: Text(board?.name ?? "Tasks"),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Expanded(
                    child: SearchField(
                      hint: "Task title, owner, sprint, etc",
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        // TODO: Tasks filtering
                      },
                      icon: const Icon(Icons.filter_list))
                ],
              ),
            ),
          ),
          Expanded(
              child: TasksList(
            tasks: board?.tasks ?? tasks ?? [],
          )),
        ],
      ),
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
      ));
}