import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:intl/intl.dart';
import 'package:mobile_dashboard/utils/extensions.dart';

class CreateEditSprintScreen extends StatefulWidget {
  const CreateEditSprintScreen({super.key, this.restorationId});

  final String? restorationId;

  @override
  State<CreateEditSprintScreen> createState() => _CreateEditSprintScreenState();
}

class _CreateEditSprintScreenState extends State<CreateEditSprintScreen>
    with RestorationMixin {
  final TasksRepository _tasksRepo = GetIt.instance<TasksRepository>();

  late Sprint _sprint;

  final _controllerName = TextEditingController();
  String? _startDate;
  String? _endDate;

  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _startSelectedDate =
      RestorableDateTime(DateTime.now());

  late final RestorableRouteFuture<DateTime?> _startDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectStartDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _startSelectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  final RestorableDateTime _endSelectedDate =
      RestorableDateTime(DateTime.now());

  late final RestorableRouteFuture<DateTime?> _endDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectEndDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _endSelectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_startSelectedDate, 'start_selected_date');
    registerForRestoration(_endSelectedDate, 'end_selected_date');
    registerForRestoration(
        _startDatePickerRouteFuture, 'start_date_picker_route_future');
    registerForRestoration(
        _endDatePickerRouteFuture, 'end_date_picker_route_future');
  }

  void _selectStartDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _startDate = newSelectedDate.truncatedToDay();
        _startSelectedDate.value = newSelectedDate;
      });
    }
  }

  void _selectEndDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _endDate = newSelectedDate.truncatedToDay();
        _endSelectedDate.value = newSelectedDate;
      });
    }
  }

  @override
  void dispose() {
    _controllerName.dispose();

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
            title: const Text("Create sprint"),
            actions: [
              IconButton(
                  onPressed: () {
                    _sprint = Sprint(
                        id: "id",
                        name: _controllerName.text,
                        startDate: _startDate,
                        endDate: _endDate);
                    _tasksRepo.addSprint(_sprint);

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check))
            ],
          ),
          body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(
                  left: 24, top: 30, right: 24, bottom: 16),
              child: Column(
                children: [
                  TextField(
                      controller: _controllerName,
                      maxLength: 50,
                      maxLines: 1,
                      decoration: const InputDecoration(labelText: "Name")),
                  Row(
                    children: [
                      Text("Start date: ${_startDate ?? ""}"),
                      const SizedBox(
                        width: 20,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _startDatePickerRouteFuture.present();
                        },
                        child: const Text('Open Calendar'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("End date: ${_endDate ?? ""}"),
                      const SizedBox(
                        width: 20,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _endDatePickerRouteFuture.present();
                        },
                        child: const Text('Open Calendar'),
                      ),
                    ],
                  ),
                ],
              ))));
}