import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/projects_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';

class RepositoryScreen extends StatefulWidget {
  const RepositoryScreen({super.key});

  @override
  State<RepositoryScreen> createState() => _RepositoryScreenState();
}

class _RepositoryScreenState extends State<RepositoryScreen> {
  final ProjectsRepository _repo = GetIt.instance();

  final TextEditingController _gitHubUser = TextEditingController();
  final TextEditingController _gitHubRepo = TextEditingController();
  final TextEditingController _gitHubToken = TextEditingController();

  @override
  void initState() {
    final selectedProject = _repo.selectedProject.value;
    _gitHubUser.text = selectedProject?.gitHubUser ?? "";
    _gitHubRepo.text = selectedProject?.gitHubRepository ?? "";
    _gitHubToken.text = selectedProject?.gitHubToken ?? "";

    super.initState();
  }

  @override
  void dispose() {
    _gitHubUser.dispose();
    _gitHubRepo.dispose();
    _gitHubToken.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Configuration"),
            actions: [
              IconButton(
                  onPressed: () {
                    final selectedProject = _repo.selectedProject.value;
                    if (selectedProject == null) {
                      return;
                    }

                    final connectedProject = Project(
                        id: selectedProject.id,
                        name: selectedProject.name,
                        description: selectedProject.description,
                        gitHubUser: _gitHubUser.text,
                        gitHubRepository: _gitHubRepo.text,
                        gitHubToken: _gitHubToken.text);

                    _repo.updateProject(connectedProject);

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check))
            ],
          ),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding:
                const EdgeInsets.only(left: 24, top: 30, right: 24, bottom: 16),
            child: Column(
              children: [
                const Text("Configure the GitHub repository",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: _gitHubUser,
                  maxLines: 1,
                  decoration:
                      const InputDecoration(labelText: "GitHub Username"),
                ),
                TextField(
                  controller: _gitHubRepo,
                  maxLines: 1,
                  decoration:
                      const InputDecoration(labelText: "GitHub Repository"),
                ),
                TextField(
                  controller: _gitHubToken,
                  maxLines: 1,
                  decoration: const InputDecoration(labelText: "GitHub Token"),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      );
}