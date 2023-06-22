import 'package:flutter/cupertino.dart';
import 'package:mobile_dashboard/data/github_api.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/utils/computation/metrics.dart';
import 'package:mobile_dashboard/utils/pair.dart';

class MetricsRepository {
  final GitHubApi api;

  final List<Metric> metrics = [
    PredefinedMetric(
        name: "Velocity",
        description:
            "The number of story points completed by a team in one Sprint",
        measureUnit: "Points",
        formula: velocity),
    PredefinedMetric(
        name: "Lead Time",
        description:
            "The average time a task takes to get from created to completed in one Sprint",
        measureUnit: "Days",
        formula: averageLeadTime),
    PredefinedMetric(
        name: "Cycle Time",
        description:
            "The average time a task takes to get from in progress to completed in one Sprint",
        measureUnit: "Days",
        formula: averageCycleTime),
    PredefinedMetric(
        name: "Queue Time",
        description:
            "The average time a task takes to get from created to in progress in one Sprint",
        measureUnit: "Days",
        formula: averageQueueTime),
    PredefinedMetric(
        name: "Time in state",
        description:
            "The average time a task stays in one state (To do, In progress, Done)",
        measureUnit: "Days",
        formula: averageTimeInState),
    DynamicMetric(
        name: "Most modified files",
        description:
            "The files that have been modified the most in the repository commits history",
        measureUnit: "Modifications")
  ];

  final ValueNotifier<List<StringNumValue>> mostModifiedFiles =
      ValueNotifier(List.empty());

  MetricsRepository(this.api);

  void getMostModifiedFiles() async {
    await api
        .fetchModifiedFiles("andreimesina", "indoor",
            "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")
        .then((value) {
      print("!!! result: ${value}");
      // Count the modified files in each commit
      final fileCounts = <String, int>{};
      // for (final commitData in value) {
      //   final commitFiles = commitData['files'];
      //   for (final fileData in commitFiles) {
      //     final filename = fileData['filename'];
      //     fileCounts[filename] = (fileCounts[filename] ?? 0) + 1;
      //   }
      // }
      //
      // // Sort the files by modification count
      // final sortedFiles = fileCounts.entries.toList()
      //   ..sort((a, b) => b.value.compareTo(a.value));

      // print("!!! files: $sortedFiles");
      mostModifiedFiles.value = value;
    });
  }
}