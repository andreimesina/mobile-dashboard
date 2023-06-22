import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/projects_repository.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/performance_screen.dart';
import 'package:mobile_dashboard/screens/projects_screen.dart';
import 'package:mobile_dashboard/screens/repository_screen.dart';
import 'package:mobile_dashboard/screens/workspace/create_edit_task_screen.dart';
import 'package:mobile_dashboard/screens/workspace/workspace_screen.dart';
import 'package:mobile_dashboard/utils/computation/sprints.dart';
import 'package:mobile_dashboard/widgets/sprint_pie_chart.dart';
import 'package:mobile_dashboard/widgets/tasks_list.dart';

const double horizontalPadding = 16.0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(),
    PerformanceScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_selectedIndex == 0 ? "Mobile Dashboard" : "Performance"),
          actions: [
            if (_selectedIndex == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.notifications)),
                ),
              )
            else if (_selectedIndex == 1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RepositoryScreen(),
                            ));
                      },
                      icon: const Icon(Icons.settings)),
                ),
              ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Performance',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green[800],
          onTap: _onItemTapped,
        ),
      );
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final ProjectsRepository _projectsRepo = GetIt.instance<ProjectsRepository>();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: horizontalPadding,
                  top: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ProjectsScreen(hasBackNavigation: true)));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.keyboard_arrow_down_rounded),
                    ValueListenableBuilder(
                        valueListenable: _projectsRepo.selectedProject,
                        builder: (context, selectedProject, child) {
                          if (selectedProject == null) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return Text(selectedProject.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600));
                          }
                        })
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Divider(),
          ),
          _WorkspaceSection(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(),
          ),
          Expanded(child: _MyTasksSection())
        ],
      );
}

class _WorkspaceSection extends StatelessWidget {
  final TasksRepository _tasksRepo = GetIt.instance();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Workspace",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                        "Tap to see more details about the project",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WorkspaceScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: const Padding(
                            padding: EdgeInsets.only(
                                left: horizontalPadding,
                                right: horizontalPadding),
                            child: Text("Open"),
                          ))
                    ]),
                Align(
                  alignment: Alignment.topRight,
                  child: StreamBuilder(
                      stream: _tasksRepo.tasksStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Failed loading the tasks.");
                        }

                        return ValueListenableBuilder(
                          valueListenable: _tasksRepo.sprints,
                          builder: (context, value, child) {
                            final activeSprint =
                                _tasksRepo.sprints.value.firstOrNull;

                            if (activeSprint != null) {
                              final activeSprintTasks = snapshot.data?.where(
                                      (task) =>
                                          task.sprintId == activeSprint.id) ??
                                  List.empty();
                              final sprintProgress =
                                  activeSprintTasks.sprintCompletion();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ignore: unnecessary_const
                                  SprintPieChart(progress: sprintProgress),
                                  const SizedBox(height: 10),
                                  Text(
                                    activeSprint.name,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  if (activeSprint.timeInfo() != null)
                                    Text(
                                      "${activeSprint.timeInfo()}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                ],
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        );
                      }),
                )
              ],
            ),
          )
        ],
      );
}

class _MyTasksSection extends StatefulWidget {
  @override
  State<_MyTasksSection> createState() => _MyTasksSectionState();
}

class _MyTasksSectionState extends State<_MyTasksSection> {
  final TasksRepository _repo = GetIt.instance.get();
  final ValueNotifier<int> _myTasksNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text("My tasks",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  StreamBuilder(
                    stream: _repo.tasksStream(onlyCurrentUser: true),
                    builder: (context, snapshot) => Chip(
                        label: Text((snapshot.data?.length ?? 0).toString())),
                  )
                ],
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CreateEditTaskScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: const CircleBorder()),
                    child: const Icon(Icons.add),
                  ))
            ],
          ),
        ),
        StreamBuilder<List<Task>>(
            stream: _repo.tasksStream(onlyCurrentUser: true),
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

              _myTasksNotifier.value = tasks.data?.length ?? 0;
              return TasksList(
                tasks: tasks.data ?? List.empty(),
                limit: 3,
              );
            }),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WorkspaceScreen()));
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50))),
            child: const Padding(
              padding: EdgeInsets.only(
                  left: horizontalPadding, right: horizontalPadding),
              child: Text("View all"),
            ))
      ]);
}