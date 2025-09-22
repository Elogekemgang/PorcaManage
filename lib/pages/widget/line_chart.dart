import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction_model.dart';

class FinancialLineChart extends StatelessWidget {
  final List<Transaction> transactions;
  final String type; // 'income' or 'expense'

  const FinancialLineChart({super.key, required this.transactions, required this.type});

  @override
  Widget build(BuildContext context) {
    // Grouper les transactions par mois
    Map<String, double> monthlyTotals = {};

    for (var transaction in transactions.where((t) => t.type == type)) {
      final monthKey = '${transaction.date.year}-${transaction.date.month}';
      monthlyTotals.update(
          monthKey,
              (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount
      );
    }

    // Convertir en liste triée par date
    final sortedData = monthlyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Créer les spots pour le graphique
    final spots = sortedData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: type == 'income' ? Colors.green : Colors.red,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < sortedData.length) {
                  return Text(_formatMonth(sortedData[value.toInt()].key));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}€');
              },
              reservedSize: 40,
            ),
          ),
          rightTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: sortedData.length > 1 ? (sortedData.length - 1).toDouble() : 1,
        minY: 0,
        maxY: _getMaxY(monthlyTotals.values),
      ),
    );
  }

  double _getMaxY(Iterable<double> values) {
    if (values.isEmpty) return 100;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Ajouter 20% de marge
  }

  String _formatMonth(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final monthNames = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];

    return '${monthNames[month - 1]} ${year.toString().substring(2)}';
  }
}

// Widget pour afficher les deux courbes (revenus et dépenses) ensemble
class CombinedLineChart extends StatelessWidget {
  final List<Transaction>? transactions;

  const CombinedLineChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Grouper les revenus par mois
    Map<String, double> monthlyIncomes = {};
    Map<String, double> monthlyExpenses = {};

    for (var transaction in transactions!) {
      final monthKey = '${transaction.date.year}-${transaction.date.month}';
      if (transaction.type == 'income') {
        monthlyIncomes.update(
            monthKey,
                (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount
        );
      } else {
        monthlyExpenses.update(
            monthKey,
                (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount
        );
      }
    }

    // Convertir en listes triées par date
    final incomeData = monthlyIncomes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final expenseData = monthlyExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Créer les spots pour les deux courbes
    final incomeSpots = incomeData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final expenseSpots = expenseData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    // Déterminer les limites de l'axe X et Y
    final maxDataLength = incomeData.length > expenseData.length
        ? incomeData.length
        : expenseData.length;

    final maxYValue = _getMaxYValue(monthlyIncomes.values, monthlyExpenses.values);

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < maxDataLength) {
                  final data = incomeData.isNotEmpty ? incomeData : expenseData;
                  if (value.toInt() < data.length) {
                    return Text(_formatMonth(data[value.toInt()].key));
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}€');
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles:  AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: maxDataLength > 1 ? (maxDataLength - 1).toDouble() : 1,
        minY: 0,
        maxY: maxYValue,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final text = touchedSpot.barIndex == 0 ? 'Revenus' : 'Dépenses';
                return LineTooltipItem(
                  '$text: ${touchedSpot.y.toInt()}€',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _getMaxYValue(Iterable<double> incomes, Iterable<double> expenses) {
    final allValues = [...incomes, ...expenses];
    if (allValues.isEmpty) return 100;
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Ajouter 20% de marge
  }

  String _formatMonth(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final monthNames = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];

    return '${monthNames[month - 1]} ${year.toString().substring(2)}';
  }
}