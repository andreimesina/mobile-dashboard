import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/data/repository/users_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final bool isOwnerVisible;
  final bool isSprintVisible;
  final bool isStateVisible;
  final void Function() onClick;

  const TaskCard(
      {super.key,
      required this.task,
      required this.onClick,
      this.isOwnerVisible = true,
      this.isSprintVisible = true,
      this.isStateVisible = true});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TasksRepository _tasksRepo = GetIt.instance();
  final UsersRepository _usersRepo = GetIt.instance();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () {
            widget.onClick();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    if (widget.task.priority == TaskPriority.high)
                      const Icon(Icons.keyboard_double_arrow_up,
                          color: Colors.red)
                    else if (widget.task.priority == TaskPriority.medium)
                      const Icon(Icons.keyboard_double_arrow_up,
                          color: Colors.orange)
                    else
                      const Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                    Text(
                      widget.task.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (widget.isOwnerVisible)
                      Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Chip(
                            label: ValueListenableBuilder(
                              valueListenable: _usersRepo.users,
                              builder: (context, value, child) {
                                return Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 50),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        _usersRepo.users.value
                                            .firstWhere(
                                                (element) =>
                                                    element.id ==
                                                    widget.task.ownerId,
                                                orElse: () => User.unassigned())
                                            .name,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                );
                              },
                            ),
                            backgroundColor: Colors.green,
                          )),
                    if (widget.isSprintVisible)
                      Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Chip(
                            label: ValueListenableBuilder(
                                valueListenable: _tasksRepo.sprints,
                                builder: (context, value, child) {
                                  return Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 60),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        value
                                            .firstWhere(
                                                (element) =>
                                                    element.id ==
                                                    widget.task.sprintId,
                                                orElse: () =>
                                                    Sprint.unassigned())
                                            .name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                }),
                            backgroundColor: Colors.cyan,
                          )),
                    if (widget.isStateVisible)
                      Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Chip(
                            label: Text(widget.task.state.text),
                            backgroundColor: Colors.yellow,
                          )),
                  ],
                )
              ],
            ),
          ),
        ),
      );
}