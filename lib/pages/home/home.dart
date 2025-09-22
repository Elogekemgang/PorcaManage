import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';
import '../widget/line_chart.dart';
import '../widget/pie_chart.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord'),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: firestoreService.getTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data;
          final expenses = transactions?.where((t) => t.type == 'expense').toList();
          final incomes = transactions?.where((t) => t.type == 'income').toList();

          final totalExpenses = expenses?.fold(0.0, (sum, item) => sum + item.amount);
          final totalIncomes = incomes?.fold(0.0, (sum, item) => sum + item.amount);
          final balance = totalIncomes! - totalExpenses!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Solde global
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Solde Global', style: TextStyle(fontSize: 18)),
                        Text('${balance.toStringAsFixed(2)} €',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Soldes des dépenses et revenus
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text('Dépenses', style: TextStyle(fontSize: 16)),
                              Text('${totalExpenses.toStringAsFixed(2)} €',
                                  style: TextStyle(fontSize: 20, color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text('Revenus', style: TextStyle(fontSize: 16)),
                              Text('${totalIncomes.toStringAsFixed(2)} €',
                                  style: TextStyle(fontSize: 20, color: Colors.green)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Diagramme circulaire des dépenses par catégorie
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dépenses par Catégorie', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 16),
                        Container(
                          height: 300,
                          child: ExpensePieChart(transactions: expenses),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Histogramme des dépenses du mois
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dépenses du Mois par Catégorie', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 16),
                        // Ici vous ajouteriez votre composant d'histogramme
                        Container(
                          height: 200,
                          child: Center(child: Text('Histogramme à implémenter')),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Évolution des Revenus et Dépenses', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 16),
                        Container(
                          height: 300,
                          child: CombinedLineChart(transactions: transactions),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}