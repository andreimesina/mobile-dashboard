import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/workspace/boards_screen.dart';
import 'package:mobile_dashboard/screens/workspace/create_edit_sprint_screen.dart';
import 'package:mobile_dashboard/screens/workspace/sprint_screen.dart';
import 'package:mobile_dashboard/screens/workspace/tasks_screen.dart';
import 'package:mobile_dashboard/screens/workspace/team_screen.dart';
import 'package:mobile_dashboard/utils/computation/sprints.dart';
import 'package:mobile_dashboard/widgets/sprint_pie_chart.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: "Tasks", icon: Icon(Icons.list_alt)),
                Tab(text: "Boards", icon: Icon(Icons.checklist)),
                Tab(text: "Sprints", icon: Icon(Icons.incomplete_circle)),
                Tab(text: "Q&A", icon: Icon(Icons.question_answer)),
                Tab(text: "Team", icon: Icon(Icons.people)),
              ],
              isScrollable: true,
            ),
            title: const Text('Workspace'),
          ),
          body: TabBarView(
            children: [
              _TasksTabContent(),
              const BoardsScreen(),
              _SprintsScreen(),
              const Icon(Icons.directions_bike),
              const TeamScreen(),
            ],
          ),
        ),
      );
}

class _TasksTabContent extends StatefulWidget {
  @override
  State<_TasksTabContent> createState() => _TasksTabContentState();
}

class _TasksTabContentState extends State<_TasksTabContent> {
  final TasksRepository _repo = GetIt.instance.get();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Task>>(
      stream: _repo.tasksStream(onlyCurrentUser: false),
      builder: (context, tasks) {
        if (tasks.hasError) {
          return Column(
            children: const [
              SizedBox(height: 100),
              Center(child: Text("Failed to fetch tasks.")),
              SizedBox(height: 100),
            ],
          );
        }

        if (tasks.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return TasksScreen(tasks: tasks.data ?? List.empty(), showTitle: false);
      });
}

class _SprintsScreen extends StatefulWidget {
  @override
  State<_SprintsScreen> createState() => _SprintsScreenState();
}

class _SprintsScreenState extends State<_SprintsScreen> {
  final TasksRepository _repo = GetIt.instance.get();

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEditSprintScreen(),
                ));
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
        body: ValueListenableBuilder(
          valueListenable: _repo.sprints,
          builder: (context, value, child) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: _repo.sprints.value
                  .where((element) => element.id != "-1")
                  .map((sprint) => StreamBuilder(
                      stream: _repo.tasksStream(),
                      builder: (context, snapshot) {
                        final sprintTasks = snapshot.data?.where(
                                (element) => element.sprintId == sprint.id) ??
                            List.empty();

                        final double sprintProgress =
                            sprintTasks.sprintCompletion();

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SprintScreen(sprint: sprint)));
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        sprint.name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          "Completion: ${sprintProgress.toString()}%",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey)),
                                    ),
                                    if (sprint.timeInfo() != null)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(sprint.timeInfo()!,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                      )
                                  ],
                                ),
                                SprintPieChart(progress: sprintProgress)
                              ]),
                        );
                      }))
                  .toList(),
            ),
          ),
        ),
      );
}