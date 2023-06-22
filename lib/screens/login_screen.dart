import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/github_api.dart';
import 'package:mobile_dashboard/data/repository/metrics_repository.dart';
import 'package:mobile_dashboard/screens/projects_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final MetricsRepository _repo = GetIt.instance();

  @override
  void initState() {
    print("!!! run GitHub");

    _repo.getMostModifiedFiles();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Login"),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: LoginFieldWidget(title: "E-mail")),
              const Padding(
                  padding: EdgeInsets.only(left: 24.0, right: 24.0),
                  child: LoginFieldWidget(title: "Password")),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 64.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProjectsScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text("Log in")),
                ),
              )),
            ],
          ),
        ),
      );
}

class LoginFieldWidget extends StatefulWidget {
  const LoginFieldWidget({super.key, required this.title});

  final String title;

  @override
  State<LoginFieldWidget> createState() => _LoginFieldWidgetState();
}

class _LoginFieldWidgetState extends State<LoginFieldWidget> {
  @override
  Widget build(BuildContext context) => TextField(
        decoration: InputDecoration(hintText: widget.title),
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