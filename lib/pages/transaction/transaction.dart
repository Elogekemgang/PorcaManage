import 'package:flutter/material.dart';
import 'package:porcamanage/pages/transaction/transaction_form.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class Transactions extends StatelessWidget {
  const Transactions({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Section Dépenses
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Dépenses Total: ${totalExpenses?.toStringAsFixed(2)} €',
                            style: TextStyle(fontSize: 18, color: Colors.red)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showTransactionDialog(context, 'expense'),
                          child: Text('Ajouter une Dépense'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Section Revenus
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Revenus Total: ${totalIncomes?.toStringAsFixed(2)} €',
                            style: TextStyle(fontSize: 18, color: Colors.green)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showTransactionDialog(context, 'income'),
                          child: Text('Ajouter un Revenu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Bouton pour voir la liste détaillée
                ElevatedButton(
                  onPressed: () => _showDetailedList(context, transactions!),
                  child: Text('Voir Liste Détailée des Transactions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => TransactionForm(type: type,),
    );
  }

  void _showDetailedList(BuildContext context, List<Transaction> transactions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Liste des Transactions'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                title: Text(transaction.title),
                subtitle: Text('${transaction.amount} € - ${transaction.category}'),
                trailing: Text(transaction.date.toString().substring(0, 10)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }
}