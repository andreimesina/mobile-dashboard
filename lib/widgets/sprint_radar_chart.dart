import 'package:flutter/cupertino.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

class SprintRadarChart extends StatelessWidget {
  final List<String> features = [
    "Velocity",
    "Lead Time",
    "Cycle Time",
    "Queue Time",
    "Time in state"
  ];
  final List<List<num>> data;

  List<List<num>> get _finalData =>
      data.map((graph) => graph.sublist(0, features.length.floor())).toList();

  SprintRadarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) => RadarChart.light(
        ticks: const [1, 2, 4, 6],
        features: features,
        data: _finalData,
        reverseAxis: false,
        useSides: true,
      );
}