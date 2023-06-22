import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/workspace/create_edit_task_screen.dart';
import 'package:mobile_dashboard/screens/workspace/tasks_screen.dart';
import 'package:mobile_dashboard/widgets/task_card.dart';
import 'package:mobile_dashboard/widgets/tasks_list.dart';
import 'package:dotted_line/dotted_line.dart';

class BoardCard extends StatelessWidget {
  final Board board;

  const BoardCard({super.key, required this.board});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TasksScreen(showTitle: true, board: board)));
        },
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        board.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Chip(label: Text(board.tasks.length.toString())),
                    ],
                  ),
                )),
            ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: min(3, board.tasks.length),
              itemBuilder: (context, index) {
                return TaskCard(
                    task: board.tasks[index],
                    onClick: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateEditTaskScreen(
                                  currentTask: board.tasks[index])));
                    });
              },
            ),
            if (board.tasks.length > 3)
              Column(
                children: const [
                  DottedLine(
                    lineLength: 40,
                    lineThickness: 10,
                    dashLength: 10,
                    dashColor: Colors.grey,
                    dashRadius: 8,
                  ),
                  SizedBox(height: 16)
                ],
              ),
          ],
        ),
      );
}