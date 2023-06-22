import 'dart:math';

import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/utils/extensions.dart';

extension SprintFormulas on Sprint {
  int? daysUntilStart() => startDateObject()?.difference(DateTime.now()).inDays;

  int? daysUntilEnd() => endDateObject()?.difference(DateTime.now()).inDays;

  String? timeInfo() {
    String? text;
    final int? daysBeforeStart = daysUntilStart();
    final int? daysBeforeEnd = daysUntilEnd();

    if (daysBeforeStart == null || daysBeforeEnd == null) {
      return null;
    }

    if (daysBeforeStart > 1) {
      text = "Starts in $daysBeforeStart days";
    } else if (daysBeforeStart > 0) {
      text = "Starts in $daysBeforeStart day";
    } else if (daysBeforeStart == 0) {
      text = "Starts today";
    } else if (daysBeforeEnd > 1) {
      text = "Ends in $daysBeforeEnd days";
    } else if (daysBeforeEnd > 0) {
      text = "Ends in $daysBeforeEnd day";
    } else if (daysBeforeEnd == 0) {
      text = "Ends today";
    } else if (daysBeforeEnd < -1) {
      text = "Ended ${-1 * daysBeforeEnd} days ago";
    } else if (daysBeforeEnd < 0) {
      text = "Ended ${-1 * daysBeforeEnd} day ago";
    }

    return text;
  }
}

extension TasksFormulas on Iterable<Task> {
  double sprintCompletion() =>
      100 *
      where((task) => task.state == TaskState.done).length /
      max(length, 1);

  int sprintTotalPoints() => map((task) => task.storyPoints).fold(
      0, (previousTaskPoints, taskPoints) => previousTaskPoints + taskPoints);
}