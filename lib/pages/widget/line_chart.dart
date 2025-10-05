import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction_model.dart';

class FinancialLineChart extends StatefulWidget {
  final List<Transaction> transactions;
  final String type; // 'income' or 'expense'

  const FinancialLineChart({super.key, required this.transactions, required this.type});

  @override
  State<FinancialLineChart> createState() => _FinancialLineChartState();
}

class _FinancialLineChartState extends State<FinancialLineChart> {
  TimePeriod _selectedPeriod = TimePeriod.month;

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = widget.transactions.where((t) => t.type == widget.type).toList();

    return Column(
      children: [
        // En-tête avec contrôles
        _buildChartHeader(),
        SizedBox(height: 16),
        // Graphique
        _buildChart(filteredTransactions),
      ],
    );
  }

  Widget _buildChartHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _getChartTitle(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        // Sélecteur de période
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<TimePeriod>(
            value: _selectedPeriod,
            onChanged: (TimePeriod? newValue) {
              setState(() {
                _selectedPeriod = newValue!;
              });
            },
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, size: 16),
            items: TimePeriod.values.map((TimePeriod period) {
              return DropdownMenuItem<TimePeriod>(
                value: period,
                child: Text(
                  _getPeriodLabel(period),
                  style: TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<Transaction> filteredTransactions) {
    if (filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    final chartData = _prepareChartData(filteredTransactions);

    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: chartData.spots,
              isCurved: true,
              color: widget.type == 'income' ? Colors.green : Colors.red,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: widget.type == 'income'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: widget.type == 'income' ? Colors.green : Colors.red,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < chartData.labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        chartData.labels[value.toInt()] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}F',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
                interval: _getYAxisInterval(chartData.maxY),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200],
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          minX: 0,
          maxX: chartData.spots.length > 1 ? (chartData.spots.length - 1).toDouble() : 1,
          minY: 0,
          maxY: chartData.maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey[800]!,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final label = chartData.tooltipLabels[touchedSpot.spotIndex] ?? '';
                  return LineTooltipItem(
                    '$label\n${touchedSpot.y.toInt()} FCFA',
                    TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'Aucune donnée',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Ajoutez des transactions pour voir le graphique',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ChartData _prepareChartData(List<Transaction> transactions) {
    switch (_selectedPeriod) {
      case TimePeriod.day:
        return _prepareDailyData(transactions);
      case TimePeriod.week:
        return _prepareWeeklyData(transactions);
      case TimePeriod.month:
        return _prepareMonthlyData(transactions);
    }
  }

  ChartData _prepareDailyData(List<Transaction> transactions) {
    final now = DateTime.now();
    final Map<String, double> dailyTotals = {};
    final List<String> labels = [];
    final Map<int, String> tooltipLabels = {};

    // Initialiser les 7 derniers jours
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.day}/${date.month}';
      dailyTotals[key] = 0.0;
      labels.add('${date.day}/${date.month}');
    }

    // Remplir avec les données réelles
    for (var transaction in transactions) {
      if (transaction.date.isAfter(now.subtract(Duration(days: 7)))) {
        final key = '${transaction.date.day}/${transaction.date.month}';
        dailyTotals.update(
          key,
              (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    // Créer les spots et les labels de tooltip
    final spots = <FlSpot>[];
    for (int i = 0; i < labels.length; i++) {
      final key = labels[i];
      final value = dailyTotals[key] ?? 0.0;
      tooltipLabels[i] = key;
      spots.add(FlSpot(i.toDouble(), value));
    }

    final maxY = dailyTotals.values.fold(0.0, (max, value) => value > max ? value : max) * 1.2;

    return ChartData(spots, labels, tooltipLabels, maxY);
  }

  ChartData _prepareWeeklyData(List<Transaction> transactions) {
    final now = DateTime.now();
    final Map<String, double> weeklyTotals = {};
    final List<String> labels = [];
    final Map<int, String> tooltipLabels = {};

    // 4 dernières semaines
    for (int i = 3; i >= 0; i--) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1 + i * 7));
      final weekNumber = _getWeekNumber(startOfWeek);
      final key = 'S$weekNumber';
      weeklyTotals[key] = 0.0;
      labels.add('S$weekNumber');
    }

    for (var transaction in transactions) {
      final weekKey = 'S${_getWeekNumber(transaction.date)}';
      if (weeklyTotals.containsKey(weekKey)) {
        weeklyTotals[weekKey] = weeklyTotals[weekKey]! + transaction.amount;
      }
    }

    // Créer les spots
    final spots = <FlSpot>[];
    for (int i = 0; i < labels.length; i++) {
      final key = labels[i];
      final value = weeklyTotals[key] ?? 0.0;
      tooltipLabels[i] = 'Semaine $key';
      spots.add(FlSpot(i.toDouble(), value));
    }

    final maxY = weeklyTotals.values.fold(0.0, (max, value) => value > max ? value : max) * 1.2;

    return ChartData(spots, labels, tooltipLabels, maxY);
  }

  ChartData _prepareMonthlyData(List<Transaction> transactions) {
    final now = DateTime.now();
    final Map<String, double> monthlyTotals = {};
    final List<String> labels = [];
    final Map<int, String> tooltipLabels = {};

    // 6 derniers mois - CORRECTION ICI
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      final key = '${date.year}-${date.month}';
      monthlyTotals[key] = 0.0;
      labels.add(_formatMonth(key));
    }

    // Remplir avec les données réelles - CORRECTION ICI
    for (var transaction in transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month}';
      if (monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] = monthlyTotals[monthKey]! + transaction.amount;
      }
    }

    // Créer les spots - CORRECTION ICI
    final spots = <FlSpot>[];
    for (int i = 0; i < labels.length; i++) {
      // Récupérer la clé originale correspondante
      final date = DateTime(now.year, now.month - (5 - i));
      final originalKey = '${date.year}-${date.month}';
      final value = monthlyTotals[originalKey] ?? 0.0;
      tooltipLabels[i] = '${labels[i]} ${now.year.toString().substring(2)}';
      spots.add(FlSpot(i.toDouble(), value));
    }

    final maxY = monthlyTotals.values.fold(0.0, (max, value) => value > max ? value : max) * 1.2;
    if (maxY == 0) return ChartData(spots, labels, tooltipLabels, 100); // Éviter maxY = 0

    return ChartData(spots, labels, tooltipLabels, maxY);
  }
  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final days = date.difference(firstDay).inDays;
    return ((days + firstDay.weekday + 1) / 7).ceil();
  }

  int _getMonthNumber(String monthLabel) {
    final monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return monthNames.indexOf(monthLabel) + 1;
  }

  double _getYAxisInterval(double maxY) {
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    return 2000;
  }

  String _getChartTitle() {
    final typeText = widget.type == 'income' ? 'Revenus' : 'Dépenses';
    final periodText = _getPeriodLabel(_selectedPeriod);
    return '$typeText - $periodText';
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.day:
        return '7 jours';
      case TimePeriod.week:
        return '4 semaines';
      case TimePeriod.month:
        return '6 mois';
    }
  }

  String _formatMonth(String monthKey) {
    final parts = monthKey.split('-');
    final month = int.parse(parts[1]);
    final monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return monthNames[month - 1];
  }
}
class CombinedLineChart extends StatefulWidget {
  final List<Transaction>? transactions;

  const CombinedLineChart({super.key, required this.transactions});

  @override
  State<CombinedLineChart> createState() => _CombinedLineChartState();
}

class _CombinedLineChartState extends State<CombinedLineChart> {
  TimePeriod _selectedPeriod = TimePeriod.month;

  @override
  Widget build(BuildContext context) {
    if (widget.transactions == null || widget.transactions!.isEmpty) {
      return _buildEmptyState();
    }

    final chartData = _prepareCombinedChartData();

    return Column(
      children: [
        _buildCombinedChartHeader(),
        SizedBox(height: 16),
        _buildCombinedChart(chartData),
      ],
    );
  }

  Widget _buildCombinedChartHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Revenus vs Dépenses - ${_getPeriodLabel(_selectedPeriod)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<TimePeriod>(
            value: _selectedPeriod,
            onChanged: (TimePeriod? newValue) {
              setState(() {
                _selectedPeriod = newValue!;
              });
            },
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, size: 16),
            items: TimePeriod.values.map((TimePeriod period) {
              return DropdownMenuItem<TimePeriod>(
                value: period,
                child: Text(
                  _getPeriodLabel(period),
                  style: TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedChart(CombinedChartData chartData) {
    // DEBUG: Afficher les données
    print('📊 Données graphique combiné:');
    print('Revenus spots: ${chartData.incomeSpots}');
    print('Dépenses spots: ${chartData.expenseSpots}');
    print('Labels: ${chartData.labels}');
    print('MaxY: ${chartData.maxY}');

    return Container(
      height: 280,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            // Revenus
            LineChartBarData(
              spots: chartData.incomeSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.1),
              ),
              dotData: FlDotData(show: true),
            ),
            // Dépenses
            LineChartBarData(
              spots: chartData.expenseSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.1),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < chartData.labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        chartData.labels[value.toInt()] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}F',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200],
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          minX: 0,
          maxX: chartData.maxX,
          minY: 0,
          maxY: chartData.maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey[800]!,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final text = touchedSpot.barIndex == 0 ? 'Revenus' : 'Dépenses';
                  final label = chartData.tooltipLabels[touchedSpot.spotIndex] ?? '';
                  return LineTooltipItem(
                    '$text - $label\n${touchedSpot.y.toInt()} FCFA',
                    TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
            SizedBox(height: 12),
            Text('Aucune donnée', style: TextStyle(color: Colors.grey[600])),
            Text('Ajoutez des transactions', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  CombinedChartData _prepareCombinedChartData() {
    final now = DateTime.now();
    final List<String> labels = [];
    final Map<int, String> tooltipLabels = {};
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];

    // Initialiser les structures de données selon la période
    final Map<String, double> incomeTotals = {};
    final Map<String, double> expenseTotals = {};

    switch (_selectedPeriod) {
      case TimePeriod.day:
      // 7 derniers jours
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final key = '${date.day}/${date.month}';
          labels.add(key);
          incomeTotals[key] = 0.0;
          expenseTotals[key] = 0.0;
        }
        break;

      case TimePeriod.week:
      // 4 dernières semaines
        for (int i = 3; i >= 0; i--) {
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1 + i * 7));
          final weekNumber = _getWeekNumber(startOfWeek);
          final key = 'S$weekNumber';
          labels.add(key);
          incomeTotals[key] = 0.0;
          expenseTotals[key] = 0.0;
        }
        break;

      case TimePeriod.month:
      // 6 derniers mois
        for (int i = 5; i >= 0; i--) {
          final date = DateTime(now.year, now.month - i);
          final key = '${date.year}-${date.month}';
          final label = _formatMonth(key);
          labels.add(label);
          incomeTotals[key] = 0.0;
          expenseTotals[key] = 0.0;
        }
        break;
    }

    // Remplir avec les données réelles
    for (final transaction in widget.transactions!) {
      String key;

      switch (_selectedPeriod) {
        case TimePeriod.day:
          key = '${transaction.date.day}/${transaction.date.month}';
          break;
        case TimePeriod.week:
          key = 'S${_getWeekNumber(transaction.date)}';
          break;
        case TimePeriod.month:
          key = '${transaction.date.year}-${transaction.date.month}';
          break;
      }

      if (incomeTotals.containsKey(key)) {
        if (transaction.type == 'income') {
          incomeTotals[key] = incomeTotals[key]! + transaction.amount;
        } else {
          expenseTotals[key] = expenseTotals[key]! + transaction.amount;
        }
      }
    }

    // Créer les spots pour le graphique
    for (int i = 0; i < labels.length; i++) {
      String key;

      switch (_selectedPeriod) {
        case TimePeriod.day:
          key = labels[i];
          break;
        case TimePeriod.week:
          key = labels[i];
          break;
        case TimePeriod.month:
        // Pour les mois, on doit reconstruire la clé originale
          final date = DateTime(now.year, now.month - (5 - i));
          key = '${date.year}-${date.month}';
          break;
      }

      tooltipLabels[i] = labels[i];
      incomeSpots.add(FlSpot(i.toDouble(), incomeTotals[key] ?? 0.0));
      expenseSpots.add(FlSpot(i.toDouble(), expenseTotals[key] ?? 0.0));
    }

    // Calculer le maxY
    final allValues = [...incomeTotals.values, ...expenseTotals.values];
    final maxY = allValues.fold<double>(0.0, (prev, val) => val > prev ? val : prev) * 1.2;

    return CombinedChartData(
      incomeSpots,
      expenseSpots,
      labels,
      tooltipLabels,
      labels.length > 1 ? (labels.length - 1).toDouble() : 1,
      maxY == 0 ? 100 : maxY, // Éviter maxY = 0
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final days = date.difference(firstDay).inDays;
    return ((days + firstDay.weekday + 1) / 7).ceil();
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.day:
        return '7 jours';
      case TimePeriod.week:
        return '4 semaines';
      case TimePeriod.month:
        return '6 mois';
    }
  }

  String _formatMonth(String monthKey) {
    final parts = monthKey.split('-');
    final month = int.parse(parts[1]);
    final monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return monthNames[month - 1];
  }
}
// Enums et classes de données
enum TimePeriod { day, week, month }

class ChartData {
  final List<FlSpot> spots;
  final List<String> labels;
  final Map<int, String> tooltipLabels;
  final double maxY;

  ChartData(this.spots, this.labels, this.tooltipLabels, this.maxY);
}

class CombinedChartData {
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;
  final List<String> labels;
  final Map<int, String> tooltipLabels;
  final double maxX;
  final double maxY;

  CombinedChartData(
      this.incomeSpots,
      this.expenseSpots,
      this.labels,
      this.tooltipLabels,
      this.maxX,
      this.maxY,
      );
}