import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/projects_repository.dart';
import 'package:mobile_dashboard/data/repository/users_repository.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final UsersRepository _usersRepo = GetIt.instance();
  final ProjectsRepository _projectsRepo = GetIt.instance();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable: _usersRepo.users,
      builder: (context, value, child) {
        final projectTeam = _usersRepo.users.value
            .where((element) => element.projectsIds
                .contains(_projectsRepo.selectedProject.value?.id))
            .toList();

        return ListView.builder(
            itemCount: projectTeam.length,
            itemBuilder: (context, index) => Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          projectTeam[index].name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (projectTeam[index].githubUser != null)
                        const SizedBox(height: 6),
                      if (projectTeam[index].githubUser != null)
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "GitHub: @${projectTeam[index].githubUser}")),
                      const SizedBox(height: 8),
                      const Divider()
                    ],
                  ),
                ));
      });
}