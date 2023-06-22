import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class SprintPieChart extends StatelessWidget {
  final double progress;

  const SprintPieChart({super.key, required this.progress});

  @override
  Widget build(BuildContext context) => PieChart(
        dataMap: {"Progress": max(progress, 1)},
        chartRadius: 90,
        chartLegendSpacing: 0,
        colorList: const [Colors.yellow],
        legendOptions: const LegendOptions(showLegends: false),
        chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            decimalPlaces: 0,
            showChartValues: progress > 0,
            showChartValuesInPercentage: true),
        baseChartColor: Colors.cyan,
        totalValue: 100.0,
      );
}