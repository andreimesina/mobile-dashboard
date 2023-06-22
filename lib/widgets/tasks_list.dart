import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/workspace/create_edit_task_screen.dart';
import 'package:mobile_dashboard/widgets/task_card.dart';

class TasksList extends StatelessWidget {
  final List<Task> tasks;
  final bool isOwnerVisible;
  final bool isSprintVisible;
  final bool isStateVisible;
  final bool hasOverscroll;
  final int? limit;

  const TasksList(
      {super.key,
      required this.tasks,
      this.isOwnerVisible = true,
      this.isSprintVisible = true,
      this.isStateVisible = true,
      this.hasOverscroll = true,
      this.limit});

  @override
  Widget build(BuildContext context) => Material(
        child: ScrollConfiguration(
          behavior: hasOverscroll
              ? const ScrollBehavior().copyWith(overscroll: true)
              : _NoOverscrollBehavior(),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            itemCount: min(tasks.length, limit ?? double.maxFinite.toInt()),
            itemBuilder: (BuildContext context, int index) {
              if (index < (limit ?? double.maxFinite.toInt())) {
                return TaskCard(
                    task: tasks[index],
                    onClick: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateEditTaskScreen(
                                currentTask: tasks[index])),
                      );
                    },
                    isOwnerVisible: isOwnerVisible,
                    isSprintVisible: isSprintVisible,
                    isStateVisible: isStateVisible);
              }
            },
          ),
        ),
      );
}

class _NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}