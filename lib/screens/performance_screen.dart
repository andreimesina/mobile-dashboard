import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_dashboard/data/github_api.dart';
import 'package:mobile_dashboard/data/repository/metrics_repository.dart';
import 'package:mobile_dashboard/data/repository/tasks_repository.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:mobile_dashboard/screens/metric_screen.dart';
import 'package:mobile_dashboard/utils/computation/metrics.dart';
import 'package:mobile_dashboard/widgets/sprint_radar_chart.dart';

const graphColors = [
  Colors.green,
  Colors.blue,
  Colors.red,
  Colors.orange,
];

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final TasksRepository _tasksRepo = GetIt.instance();
  final MetricsRepository _metricsRepo = GetIt.instance();

  final ValueNotifier<List<String>> _selectedSprintsIds =
      ValueNotifier(List.empty());

  final ValueNotifier<Map<Sprint, List<Task>>> _sprintTasksMap =
      ValueNotifier(Map.fromEntries(List.empty()));

  final ValueNotifier<List<MetricValuesForSprints>> _sprintsMetrics =
      ValueNotifier(List.empty());

  @override
  void initState() {
    print("!!! perf init");

    _sprintTasksMap.addListener(() {
      final List<MetricValuesForSprints> metricsValuesForAllSprints =
          List.empty(growable: true);

      _metricsRepo.metrics.whereType<PredefinedMetric>().forEach((metric) {
        final List<SprintMetricValue> sprintMetricPairs =
            List.empty(growable: true);

        _sprintTasksMap.value.forEach((sprint, tasks) {
          final double metricValueForThisSprint = metric.formula(tasks);
          sprintMetricPairs
              .add(SprintMetricValue(sprint, metricValueForThisSprint));
        });

        metricsValuesForAllSprints.add(MetricValuesForSprints(
            metric: metric, sprintMetricPairs: sprintMetricPairs));
      });

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _sprintsMetrics.value = metricsValuesForAllSprints;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _selectedSprintsIds.dispose();
    _sprintTasksMap.dispose();
    _sprintsMetrics.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable: _selectedSprintsIds,
      builder: (context, value, child) => Column(
            children: [
              const SizedBox(height: 16),
              StreamBuilder(
                  stream: _tasksRepo.tasksStream(),
                  builder: (context, snapshot) {
                    // Create a map with sprintIds of the selected sprints to
                    // their corresponding tasks list
                    final tasks = {
                      for (var sprintId in _selectedSprintsIds.value)
                        sprintId: (snapshot.data ?? List.empty())
                            .where((task) => task.sprintId == sprintId)
                            .toList()
                    };

                    // print("!!! tasks: ${tasks.length}");
                    _sprintTasksMap.value = tasks.map((key, value) => MapEntry(
                        _tasksRepo.sprints.value
                            .firstWhere((sprint) => sprint.id == key),
                        value));

                    // print(
                    //     "!!! sprintTasksMap listeners: ${_sprintTasksMap.hasListeners}");
                    // tasks.removeWhere((key, value) =>
                    //     _selectedSprintsIds.value.contains(key) == false);

                    final List<List<num>> data = [];
                    tasks.forEach((sprintId, tasks) {
                      data.add([
                        velocity(tasks),
                        averageLeadTime(tasks),
                        averageCycleTime(tasks),
                        averageQueueTime(tasks),
                        averageTimeInState(tasks)
                      ]);
                    });

                    // var data = [
                    //   [10.0, 20, 7, 5, 16, 15, 17, 6],
                    //   [14.5, 1, 4, 14, 23, 10, 6, 19],
                    //   [1.5, 14, 6, 9, 15, 17, 4, 10],
                    //   [19, 6, 12, 12, 5, 16, 9, 12],
                    // ];
                    return Container(
                        constraints:
                            const BoxConstraints(maxWidth: 300, maxHeight: 300),
                        child: SprintRadarChart(data: data));
                  }),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedSprintsIds.value.isNotEmpty)
                      SprintsLegend(
                          selectedSprintsIds: _selectedSprintsIds,
                          repo: _tasksRepo),
                    if (_selectedSprintsIds.value.isNotEmpty)
                      const SizedBox(width: 30),
                    SprintsDialogButton(
                      sprints: _tasksRepo.sprints.value
                          .where((element) => element.id != "-1")
                          .toList(),
                      onSprintsConfirmed: (selected) {
                        _selectedSprintsIds.value = selected;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: _metricsRepo.mostModifiedFiles,
                builder: (context, value, child) {
                  final dynamicMetricsValues =
                      _metricsRepo.mostModifiedFiles.value;

                  return ValueListenableBuilder(
                      valueListenable: _sprintsMetrics,
                      builder: (context, value, child) => MetricsSection(
                            metrics: _metricsRepo.metrics,
                            sprintsMetrics: _sprintsMetrics.value,
                            dynamicMetricsValues: dynamicMetricsValues,
                          ));
                },
              )
            ],
          ));
}

class SprintsLegend extends StatelessWidget {
  const SprintsLegend({
    super.key,
    required ValueNotifier<List<String>> selectedSprintsIds,
    required TasksRepository repo,
  })  : _selectedSprintsIds = selectedSprintsIds,
        _repo = repo;

  final ValueNotifier<List<String>> _selectedSprintsIds;
  final TasksRepository _repo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedSprintsIds.value
          .map((sprintId) => _repo.sprints.value
              .firstWhere((element) => element.id == sprintId))
          .toList()
          .mapIndexed((index, sprint) => Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: graphColors.firstWhereIndexedOrNull(
                                (colorIndex, element) => colorIndex == index) ??
                            Colors.white24,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(sprint.name)
                ],
              ))
          .toList(),
    );
  }
}

class SprintsDialogButton extends StatefulWidget {
  final List<Sprint> sprints;
  final Function(List<String>) onSprintsConfirmed;

  const SprintsDialogButton({
    super.key,
    required this.sprints,
    required this.onSprintsConfirmed,
  });

  @override
  State<SprintsDialogButton> createState() => _SprintsDialogButtonState();
}

class _SprintsDialogButtonState extends State<SprintsDialogButton> {
  final ValueNotifier<List<String>> _selectedSprintsIds =
      ValueNotifier(List.empty());

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Select up to 4 sprints',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.sprints.length,
                              itemBuilder: (context, index) => InkWell(
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(widget.sprints[index].name),
                                          ValueListenableBuilder(
                                            valueListenable:
                                                _selectedSprintsIds,
                                            builder: (context, value, child) =>
                                                Checkbox(
                                              value: _selectedSprintsIds.value
                                                  .contains(
                                                      widget.sprints[index].id),
                                              onChanged: (value) {
                                                final sprintId =
                                                    widget.sprints[index].id;

                                                if (_selectedSprintsIds.value
                                                    .contains(sprintId)) {
                                                  _selectedSprintsIds.value =
                                                      _selectedSprintsIds.value
                                                          .where((element) =>
                                                              element !=
                                                              sprintId)
                                                          .toList();
                                                } else {
                                                  _selectedSprintsIds.value =
                                                      _selectedSprintsIds
                                                              .value +
                                                          [
                                                            widget
                                                                .sprints[index]
                                                                .id
                                                          ];
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                          TextButton(
                            onPressed: () {
                              widget.onSprintsConfirmed(
                                  _selectedSprintsIds.value);
                              Navigator.pop(context);
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ),
                  ));
        },
        child: const Text("Select sprints"));
  }
}

class MetricsSection extends StatelessWidget {
  const MetricsSection(
      {super.key,
      required this.metrics,
      required this.sprintsMetrics,
      required this.dynamicMetricsValues});

  final List<Metric> metrics;
  final List<MetricValuesForSprints> sprintsMetrics;

  final List<StringNumValue> dynamicMetricsValues;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text("Metrics",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                  child: Column(
                      children: metrics
                          .mapIndexed((index, metric) => InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    if (metric is PredefinedMetric) {
                                      return MetricScreen(
                                          metricForSprints: sprintsMetrics
                                              .elementAtOrNull(index),
                                          dynamicMetricValues: null);
                                    } else if (metric is DynamicMetric) {
                                      return MetricScreen(
                                          metricForSprints: null,
                                          dynamicMetricValues:
                                              DynamicMetricValues(
                                                  metric: metric,
                                                  values:
                                                      dynamicMetricsValues));
                                    } else {
                                      return Container();
                                    }
                                  }));
                                },
                                child: Column(
                                  children: [
                                    MetricBox(metric: metric),
                                    if (index < metrics.length - 1)
                                      const Divider()
                                  ],
                                ),
                              ))
                          .toList())),
            ),
          ],
        ),
      );
}

class MetricBox extends StatelessWidget {
  final Metric metric;

  const MetricBox({super.key, required this.metric});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(metric.name, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(metric.description)
          ],
        ),
      );
}