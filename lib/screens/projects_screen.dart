import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/projects_repository.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/home_screen.dart';

class ProjectsScreen extends StatefulWidget {
  final bool hasBackNavigation;

  const ProjectsScreen({super.key, this.hasBackNavigation = false});

  @override
  State<StatefulWidget> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectsRepository _repo = GetIt.instance<ProjectsRepository>();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Projects"),
          ),
          actions: [
            Center(
              child: IconButton(
                  onPressed: () {
                    // TODO: Tasks filtering
                  },
                  icon: const Icon(Icons.filter_list)),
            ),
          ],
          automaticallyImplyLeading: widget.hasBackNavigation,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: SearchFieldWidget(title: "Search")),
              StreamBuilder(
                stream: _repo.getProjects(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('You have no projects yet.');
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final projects = snapshot.data ?? List.empty();
                  return Expanded(
                      child: _ProjectsList(
                          projects: projects,
                          onProjectSelected: (Project project) {
                            _repo.selectProject(project);
                          }));
                },
              ),
            ],
          ),
        ),
      );
}

class SearchFieldWidget extends StatefulWidget {
  const SearchFieldWidget({super.key, required this.title});

  final String title;

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  @override
  Widget build(BuildContext context) => TextField(
        decoration: InputDecoration(
            hintText: widget.title,
            border: const OutlineInputBorder(),
            fillColor: Colors.grey),
        onSubmitted: (String value) async {
          await showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Thanks!'),
                content: Text(
                    'You typed "$value", which has length ${value.characters.length}.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      );
}

class _ProjectsList extends StatefulWidget {
  final List<Project> projects;
  final Function(Project) onProjectSelected;

  const _ProjectsList(
      {required this.projects, required this.onProjectSelected});

  @override
  State<StatefulWidget> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<_ProjectsList> {
  @override
  Widget build(BuildContext context) => ListView.builder(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      itemCount: widget.projects.length,
      itemBuilder: (BuildContext context, int index) => InkWell(
            onTap: () {
              widget.onProjectSelected(widget.projects[index]);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_tree_outlined,
                    color: Colors.amber,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    widget.projects[index].name,
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  "${Random().nextInt(10)}d left",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(widget.projects[index].description),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
}