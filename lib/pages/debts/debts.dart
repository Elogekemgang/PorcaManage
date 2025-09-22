import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/debt.dart';
import '../../services/firestore_service.dart';
import '../widget/debt_card.dart';
import 'debt_form_screen.dart';

class Debts extends StatelessWidget {
  const Debts({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dettes et Créances'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Dettes'),
              Tab(text: 'Créances'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDebtsTab(context, 'debt'),
            _buildDebtsTab(context, 'credit'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DebtFormScreen(type: '', existingDebt: debt,)),
            );*/
          },
          backgroundColor: Colors.yellow[700],
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDebtsTab(BuildContext context, String type) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final bool isDebt = type == 'debt';

    return StreamBuilder<List<Debt>>(
      stream: firestoreService.getDebtsByType(type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final debts = snapshot.data;
        final totalAmount = debts?.fold(0.0, (sum, debt) => sum + debt.amount);
        final pendingDebts = debts?.where((debt) => debt.status == 'pending').toList();
        final recentDebts = debts?.take(5).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        isDebt ? 'Total des Dettes' : 'Total des Créances',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '${totalAmount?.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDebt ? Colors.red : Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${pendingDebts?.length} ${isDebt ? 'dettes' : 'créances'} en attente',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DebtFormScreen(type: type, existingDebt: debt,),
                        ),
                      );*/
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDebt ? Colors.red : Colors.green,
                    ),
                    child: Text('Ajouter ${isDebt ? 'une dette' : 'une créance'}'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '${isDebt ? 'Dettes' : 'Créances'} Récentes (5)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (recentDebts!.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    isDebt ? 'Aucune dette récente' : 'Aucune créance récente',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ...recentDebts.map((debt) => DebtCard(
                debt: debt,
                onDelete: () => _deleteDebt(context, debt),
                onUpdate: () => _updateDebtStatus(context, debt),
              )),
            ],
          ),
        );
      },
    );
  }

  void _deleteDebt(BuildContext context, Debt debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette ${debt.type == 'debt' ? 'dette' : 'créance'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final firestoreService = Provider.of<FirestoreService>(context, listen: false);
              firestoreService.deleteDebt(debt.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${debt.type == 'debt' ? 'Dette' : 'Créance'} supprimée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateDebtStatus(BuildContext context, Debt debt) {
    final newStatus = debt.status == 'pending'
        ? (debt.type == 'debt' ? 'paid' : 'received')
        : 'pending';

    final updatedDebt = Debt(
      id: debt.id,
      title: debt.title,
      amount: debt.amount,
      date: debt.date,
      dueDate: debt.dueDate,
      type: debt.type,
      status: newStatus,
      person: debt.person,
      description: debt.description,
    );

    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    firestoreService.updateDebt(updatedDebt);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Statut mis à jour avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editDebt(BuildContext context, Debt debt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebtFormScreen(existingDebt: debt, type: '',),
      ),
    );
  }
}