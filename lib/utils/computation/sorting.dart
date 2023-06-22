import 'package:mobile_dashboard/domain/models.dart';
import 'package:collection/collection.dart';
import 'package:mobile_dashboard/utils/extensions.dart';

extension TasksSorting on List<Task> {
  List<Task> sortedByPriority() {
    sort((firstTask, secondTask) =>
        secondTask.priority.value.compareTo(firstTask.priority.value));

    return this;
  }
}

extension SprintsSorting on List<Sprint> {
  List<Sprint> sortedByEndDate() {
    final comparison = _compareDatesWithNow.then(_compareEndDates);
    sort(comparison);

    return this;
  }
}

int _compareEndDates(Sprint firstSprint, Sprint secondSprint) =>
    firstSprint.endDate?.compareTo(secondSprint.endDate ?? "") ?? 0;

int _compareDatesWithNow(Sprint firstSprint, Sprint secondSprint) {
  final firstDate = firstSprint.endDateObject() ??
      DateTime.now().subtract(const Duration(days: 1));
  final secondDate = secondSprint.endDateObject() ??
      DateTime.now().subtract(const Duration(days: 1));

  if (firstDate.isBefore(DateTime.now()) &&
      secondDate.isBefore(DateTime.now())) {
    return 0;
  } else if (firstDate.isBefore(DateTime.now())) {
    return 1;
  } else if (secondDate.isBefore(DateTime.now())) {
    return -1;
  } else {
    return 0;
  }
}