import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/transaction_model.dart';

class ExpensePieChart extends StatefulWidget {
  final List<Transaction>? transactions;

  const ExpensePieChart({super.key, required this.transactions});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.transactions == null || widget.transactions!.isEmpty) {
      return _buildEmptyState();
    }

    final categoryData = _calculateCategoryData();

    if (categoryData.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Graphique circulaire
        _buildPieChart(categoryData),
        SizedBox(height: 25),
        // Légende interactive
        _buildLegend(categoryData),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
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
              Icons.pie_chart_outline,
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
              'Ajoutez des dépenses pour voir\nla répartition par catégorie',
              textAlign: TextAlign.center,
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

  List<MapEntry<String, double>> _calculateCategoryData() {
    Map<String, double> categoryTotals = {};

    for (var transaction in widget.transactions!) {
      categoryTotals.update(
        transaction.category,
            (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    // Trier par montant décroissant
    final sortedData = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedData;
  }

  Widget _buildPieChart(List<MapEntry<String, double>> categoryData) {
    final totalAmount = categoryData.fold(0.0, (sum, item) => sum + item.value);

    return Container(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 4,
              centerSpaceRadius: 60,
              sections: _buildSections(categoryData, totalAmount),
            ),
          ),
          // Texte au centre
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${totalAmount.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${categoryData.length} catégories',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
      List<MapEntry<String, double>> categoryData, double totalAmount) {
    return categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final amount = entry.value.value;
      final percentage = (amount / totalAmount * 100);

      final isTouched = index == touchedIndex;
      final radius = isTouched ? 110.0 : 100.0;

      return PieChartSectionData(
        color: _getCategoryColor(category, index),
        value: amount,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
          color: Colors.white,
        ),
        borderSide: isTouched
            ? BorderSide(color: Colors.white, width: 2)
            : BorderSide(color: Colors.white.withOpacity(0.2)),
      );
    }).toList();
  }

  Widget _buildLegend(List<MapEntry<String, double>> categoryData) {
    final totalAmount = categoryData.fold(0.0, (sum, item) => sum + item.value);

    return Container(
      constraints: BoxConstraints(maxHeight: 200,),color: Colors.grey.shade50,
      child: SingleChildScrollView(
        child: Column(
          children: categoryData.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final amount = entry.value.value;
            final percentage = (amount / totalAmount * 100);
            final isTouched = index == touchedIndex;

            return _buildLegendItem(
              category: category,
              amount: amount,
              percentage: percentage,
              color: _getCategoryColor(category, index),
              isTouched: isTouched,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required String category,
    required double amount,
    required double percentage,
    required Color color,
    required bool isTouched,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTouched ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTouched ? color : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Point de couleur
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          // Nom de la catégorie
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                color: isTouched ? color : Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          // Pourcentage
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 12),
          // Montant
          Text(
            '${amount.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category, int index) {
    // Couleurs spécifiques pour les catégories communes
    final categoryColors = {
      'Nutrition': Colors.red[400]!,
      'Transport': Colors.blue[400]!,
      'Internet': Colors.purple[400]!,
      'Loyer': Colors.orange[400]!,
      'Loisir': Colors.green[400]!,
      'Santé': Colors.pink[400]!,
      'Éducation': Colors.indigo[400]!,
      'Shopping': Colors.cyan[400]!,
      'Salaire': Colors.green[600]!,
      'Cadeau': Colors.amber[600]!,
      'Vente': Colors.teal[400]!,
      'Investissement': Colors.deepPurple[400]!,
    };

    if (categoryColors.containsKey(category)) {
      return categoryColors[category]!;
    }

    // Couleurs par défaut si la catégorie n'est pas reconnue
    final defaultColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightBlue,
    ];

    return defaultColors[index % defaultColors.length];
  }
}

// Version compacte pour les petits espaces
class CompactExpensePieChart extends StatelessWidget {
  final List<Transaction>? transactions;

  const CompactExpensePieChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions == null || transactions!.isEmpty) {
      return _buildCompactEmptyState();
    }

    final categoryData = _calculateCategoryData();

    if (categoryData.isEmpty) {
      return _buildCompactEmptyState();
    }

    return Container(
      height: 180,
      child: Row(
        children: [
          // Graphique réduit
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: _buildCompactSections(categoryData),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Légende compacte
          Expanded(
            flex: 3,
            child: _buildCompactLegend(categoryData),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactEmptyState() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 32, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'Aucune donnée',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, double>> _calculateCategoryData() {
    Map<String, double> categoryTotals = {};
    for (var transaction in transactions!) {
      categoryTotals.update(
        transaction.category,
            (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  List<PieChartSectionData> _buildCompactSections(List<MapEntry<String, double>> categoryData) {
    final totalAmount = categoryData.fold(0.0, (sum, item) => sum + item.value);

    return categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final amount = entry.value.value;

      return PieChartSectionData(
        color: _getCategoryColor(category, index),
        value: amount,
        radius: 40,
        title: '',
      );
    }).toList();
  }

  Widget _buildCompactLegend(List<MapEntry<String, double>> categoryData) {
    final totalAmount = categoryData.fold(0.0, (sum, item) => sum + item.value);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categoryData.length,
      itemBuilder: (context, index) {
        final category = categoryData[index].key;
        final amount = categoryData[index].value;
        final percentage = (amount / totalAmount * 100);

        return Container(
          margin: EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category, index),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category, int index) {
    final categoryColors = {
      'Nutrition': Colors.red[400]!,
      'Transport': Colors.blue[400]!,
      'Internet': Colors.purple[400]!,
      'Loyer': Colors.orange[400]!,
      'Loisir': Colors.green[400]!,
      'Santé': Colors.pink[400]!,
      'Éducation': Colors.indigo[400]!,
      'Shopping': Colors.cyan[400]!,
    };

    if (categoryColors.containsKey(category)) {
      return categoryColors[category]!;
    }

    final defaultColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return defaultColors[index % defaultColors.length];
  }
}