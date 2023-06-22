import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile_dashboard/domain/models.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class MetricScreen extends StatelessWidget {
  final MetricValuesForSprints? metricForSprints;
  final DynamicMetricValues? dynamicMetricValues;

  const MetricScreen(
      {super.key,
      required this.metricForSprints,
      required this.dynamicMetricValues});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(metricForSprints?.metric.name ??
              dynamicMetricValues?.metric.name ??
              "Metric"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 8),
              child: Text(metricForSprints?.metric.measureUnit ??
                  dynamicMetricValues?.metric.measureUnit ??
                  ""),
            ),
            Align(
              alignment: Alignment.center,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double maxWidth = MediaQuery.of(context).size.width * 0.8;
                  double containerWidth = constraints.maxWidth > maxWidth
                      ? maxWidth
                      : constraints.maxWidth;

                  if (metricForSprints != null) {
                    return PredefinedMetricChart(
                        containerWidth: containerWidth,
                        metricForSprints: metricForSprints!);
                  } else if (dynamicMetricValues != null) {
                    return DynamicMetricChart(
                        containerWidth: containerWidth,
                        metricValues: dynamicMetricValues!);
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text("Description",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Text(
                metricForSprints?.metric.description ??
                    dynamicMetricValues?.metric.description ??
                    "Description",
                style: const TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      );
}

class PredefinedMetricChart extends StatelessWidget {
  const PredefinedMetricChart({
    super.key,
    required this.containerWidth,
    required this.metricForSprints,
  });

  final double containerWidth;
  final MetricValuesForSprints metricForSprints;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: containerWidth,
      height: 400,
      child: charts.LineChart(
        [
          charts.Series<SprintMetricValue, int>(
            id: 'Metric',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (SprintMetricValue sprintMetric, _) =>
                metricForSprints.sprintMetricPairs.indexOf(sprintMetric),
            measureFn: (SprintMetricValue sprintMetric, _) =>
                sprintMetric.value,
            data: metricForSprints.sprintMetricPairs,
          )
        ],
        animate: true,
        domainAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.StaticNumericTickProviderSpec(
              metricForSprints.sprintMetricPairs
                  .mapIndexed((index, metricValue) =>
                      charts.TickSpec(index, label: metricValue.sprint.name))
                  .toList()),
          renderSpec: const charts.SmallTickRendererSpec(
            labelRotation: 65, // Rotate the labels by 45 degrees
          ),
        ),
      ),
    );
  }
}

class DynamicMetricChart extends StatelessWidget {
  const DynamicMetricChart({
    super.key,
    required this.containerWidth,
    required this.metricValues,
  });

  final double containerWidth;
  final DynamicMetricValues metricValues;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: containerWidth,
      height: 400,
      child: charts.BarChart(
        [
          charts.Series<StringNumValue, String>(
            id: 'Metric',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (StringNumValue metricValue, _) => metricValue.name,
            measureFn: (StringNumValue metricValue, _) => metricValue.value,
            data: metricValues.values,
          )
        ],
        animate: true,
      ),
    );
  }
}