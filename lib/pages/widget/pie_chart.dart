import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction_model.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Transaction>? transactions;

  const ExpensePieChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Grouper les transactions par catégorie
    Map<String, double> categoryTotals = {};

    for (var transaction in transactions!) {
      categoryTotals.update(
          transaction.category,
              (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount
      );
    }

    // Créer les données pour le graphique
    int index = 0;
    final List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      final color = _getColor(index++);
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.value.toStringAsFixed(0)}€',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Color _getColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}