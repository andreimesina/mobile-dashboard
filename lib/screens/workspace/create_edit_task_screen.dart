import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/projects_repository.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/data/repository/users_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/utils/extensions.dart';

class CreateEditTaskScreen extends StatefulWidget {
  final Task? currentTask;

  const CreateEditTaskScreen({super.key, this.currentTask});

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final TasksRepository _tasksRepo = GetIt.instance<TasksRepository>();
  final UsersRepository _usersRepo = GetIt.instance<UsersRepository>();

  late Task _editableTask;

  final _controllerTitle = TextEditingController();
  final _controllerDescription = TextEditingController();
  final _controllerStoryPoints = TextEditingController();

  final ValueNotifier<User?> _owner = ValueNotifier(null);
  final ValueNotifier<Sprint> _sprint = ValueNotifier(Sprint.unassigned());

  final List<DropdownMenuItem> _priorityDropdown = TaskPriority.values
      .map((e) => DropdownMenuItem(value: e, child: Text(e.text)))
      .toList();
  final ValueNotifier<TaskPriority> _priority =
      ValueNotifier(TaskPriority.medium);

  final List<DropdownMenuItem> _stateDropdown = TaskState.values
      .map((e) => DropdownMenuItem(value: e, child: Text(e.text)))
      .toList();
  final ValueNotifier<TaskState> _state = ValueNotifier(TaskState.toDo);

  String get _createdDate {
    final String createdDate;

    if (widget.currentTask?.createdDate != null) {
      createdDate = widget.currentTask!.createdDate;
    } else {
      createdDate = DateTime.now().truncatedToDay();
    }

    return createdDate;
  }

  String? get _startedDate {
    final String? startedDate;

    if (widget.currentTask?.state != TaskState.inProgress &&
        _state.value == TaskState.inProgress) {
      startedDate = DateTime.now().truncatedToDay();
    } else {
      startedDate = widget.currentTask?.startedDate;
    }

    return startedDate;
  }

  String? get _completedDate {
    final String? completedDate;

    if (widget.currentTask?.state != TaskState.done &&
        _state.value == TaskState.done) {
      completedDate = DateTime.now().truncatedToDay();
    } else {
      completedDate = widget.currentTask?.startedDate;
    }

    return completedDate;
  }

  @override
  void initState() {
    _controllerTitle.text = widget.currentTask?.title ?? "";
    _controllerDescription.text = widget.currentTask?.description ?? "";
    _controllerStoryPoints.text =
        widget.currentTask?.storyPoints.toString() ?? "";

    if (widget.currentTask != null) {
      _priority.value = TaskPriority.values.firstWhere(
          (element) => element.value == widget.currentTask?.priority.value,
          orElse: () => TaskPriority.medium);

      _state.value = TaskState.values.firstWhere(
          (element) => element.value == widget.currentTask?.state.value,
          orElse: () => TaskState.toDo);
    }

    super.initState();
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    _controllerDescription.dispose();
    _controllerStoryPoints.dispose();

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
            title:
                Text(widget.currentTask != null ? "View task" : "Create task"),
            actions: [
              IconButton(
                  onPressed: () {
                    _editableTask = Task(
                        id: widget.currentTask?.id,
                        ownerId: _owner.value?.id,
                        sprintId: _sprint.value.id,
                        title: _controllerTitle.text.trim(),
                        description: _controllerDescription.text.trim(),
                        createdDate: _createdDate,
                        startedDate: _startedDate,
                        completedDate: _completedDate,
                        state: _state.value,
                        priority: _priority.value,
                        storyPoints:
                            int.tryParse(_controllerStoryPoints.text) ??
                                widget.currentTask?.storyPoints ??
                                0);

                    if (widget.currentTask == null) {
                      _tasksRepo.addTask(_editableTask);
                    } else {
                      _tasksRepo.updateTask(_editableTask);
                    }

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Summary",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                TextField(
                  controller: _controllerTitle,
                  maxLength: 256,
                  maxLines: 1,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: _controllerDescription,
                  minLines: 1,
                  maxLength: 1000,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: _controllerStoryPoints,
                  maxLines: 1,
                  decoration: const InputDecoration(labelText: "Story points"),
                ),
                const SizedBox(height: 40),
                const Text("Details",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: _usersRepo.users,
                  builder: (context, value, child) {
                    if (widget.currentTask?.ownerId != null) {
                      _owner.value = _usersRepo.users.value.firstWhere(
                          (element) =>
                              element.id == widget.currentTask?.ownerId,
                          orElse: () => User.unassigned());
                    } else {
                      _owner.value = _usersRepo.users.value.firstWhere(
                          (element) => element.id == "-1",
                          orElse: () => User.unassigned());
                    }

                    return ValueListenableBuilder(
                      valueListenable: _owner,
                      builder: (context, value, child) => DropdownButton(
                        hint: const Text("Owner"),
                        isExpanded: true,
                        icon: const Icon(Icons.person),
                        items: _usersRepo.users.value
                            .map((user) => DropdownMenuItem(
                                value: user, child: Text(user.name)))
                            .toList(),
                        value: _owner.value,
                        onChanged: (value) {
                          if (value != null) {
                            _owner.value = value;
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: _tasksRepo.sprints,
                  builder: (context, value, child) {
                    if (widget.currentTask?.sprintId != null) {
                      _sprint.value = _tasksRepo.sprints.value.firstWhere(
                          (element) =>
                              element.id == widget.currentTask?.sprintId,
                          orElse: () => Sprint.unassigned());
                    } else {
                      _sprint.value = _tasksRepo.sprints.value.firstWhere(
                          (element) => element.id == "-1",
                          orElse: () => Sprint.unassigned());
                    }

                    return ValueListenableBuilder(
                      valueListenable: _sprint,
                      builder: (context, value, child) => DropdownButton(
                        hint: const Text("Sprint"),
                        isExpanded: true,
                        icon: const Icon(Icons.incomplete_circle),
                        items: _tasksRepo.sprints.value
                            .map((sprint) => DropdownMenuItem(
                                value: sprint, child: Text(sprint.name)))
                            .toList(),
                        value: _sprint.value,
                        onChanged: (value) {
                          if (value != null) {
                            _sprint.value = value;
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: _priority,
                  builder: (context, value, child) => DropdownButton(
                    hint: const Text("Priority"),
                    items: _priorityDropdown,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_double_arrow_up),
                    value: _priority.value,
                    onChanged: (value) {
                      _priority.value = value;
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: _state,
                  builder: (context, value, child) => DropdownButton(
                    hint: const Text("State"),
                    items: _stateDropdown,
                    isExpanded: true,
                    icon: const Icon(Icons.sync_alt),
                    value: _state.value,
                    onChanged: (value) {
                      _state.value = value;
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}