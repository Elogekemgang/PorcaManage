import 'package:flutter/material.dart';
import 'package:porcamanage/customers/custom_app_bar.dart';
import 'package:porcamanage/pages/transaction/transaction_form.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../customers/colors.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class Transactions extends StatelessWidget {
  const Transactions({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: "Transactions"),
      body: StreamBuilder<List<Transaction>>(
        stream: firestoreService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final transactions = snapshot.data!;
          return _buildTransactionsContent(context, transactions);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionMenu(context),
        backgroundColor: Colors.yellow[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ), label: Row(
        spacing: 10,
        children: [
          Icon(Icons.add, color:AppColors.primary),
          Text("nouvelle transaction",style: TextStyle(fontSize: 15,color: AppColors.primary),)
        ],
      ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[700]!),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement des transactions...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Aucune transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commencez par ajouter vos premières transactions',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showTransactionMenu(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Ajouter une transaction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsContent(BuildContext context, List<Transaction> transactions) {
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    final incomes = transactions.where((t) => t.type == 'income').toList();

    final totalExpenses = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final totalIncomes = incomes.fold(0.0, (sum, item) => sum + item.amount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header avec résumé financier
          _buildFinancialSummary(totalExpenses, totalIncomes),

          SizedBox(height: 24),

          // Section dépenses
          _buildTransactionSection(
            context: context,
            title: 'Dépenses',
            amount: totalExpenses,
            transactions: expenses,
            color: Colors.red,
            type: 'expense',
          ),

          SizedBox(height: 20),

          // Section revenus
          _buildTransactionSection(
            context: context,
            title: 'Revenus',
            amount: totalIncomes,
            transactions: incomes,
            color: Colors.green,
            type: 'income',
          ),

          SizedBox(height: 20),

          // Bouton liste détaillée
          _buildDetailedListButton(context, transactions),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(double totalExpenses, double totalIncomes) {
    final balance = totalIncomes - totalExpenses;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Colors.yellow[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow[100]!,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Résumé Financier',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Solde',
                balance,
                balance >= 0 ? Colors.green[400]! : Colors.red[400]!,
                Icons.account_balance_wallet,
              ),
              _buildSummaryItem(
                'Revenus',
                totalIncomes,
                Colors.green[400]!,
                Icons.arrow_upward,
              ),
              _buildSummaryItem(
                'Dépenses',
                totalExpenses,
                Colors.red[400]!,
                Icons.arrow_downward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)} F',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionSection({
    required BuildContext context,
    required String title,
    required double amount,
    required List<Transaction> transactions,
    required Color color,
    required String type,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        type == 'expense' ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${transactions.length} transactions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${amount.toStringAsFixed(2)} FCFA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Liste des 3 dernières transactions
            if (transactions.isNotEmpty) ...[
              ...transactions.take(3).map((transaction) =>
                  _buildTransactionItem(transaction)
              ).toList(),

              if (transactions.length > 3) ...[
                SizedBox(height: 12),
                Center(
                  child: Text(
                    '+ ${transactions.length - 3} autres transactions',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Aucune transaction ${type == 'expense' ? 'de dépense' : 'de revenu'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            SizedBox(height: 16),

            // Bouton d'ajout
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showTransactionDialog(context, type),
                child: Text(
                  'Ajouter ${type == 'expense' ? 'une Dépense' : 'un Revenu'}',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: transaction.type == 'expense'
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.type == 'expense' ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: transaction.type == 'expense' ? Colors.red : Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  transaction.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.amount.toStringAsFixed(2)} FCFA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.type == 'expense' ? Colors.red : Colors.green,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                dateFormat.format(transaction.date),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedListButton(BuildContext context, List<Transaction> transactions) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showDetailedList(context, transactions),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 20),
            SizedBox(width: 8),
            Text('Voir Toutes les Transactions'),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.yellow[700],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.yellow[700]!),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showTransactionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nouvelle Transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTransactionTypeButton(
                    context: context,
                    type: 'expense',
                    title: 'Dépense',
                    color: Colors.red,
                    icon: Icons.arrow_downward,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTransactionTypeButton(
                    context: context,
                    type: 'income',
                    title: 'Revenu',
                    color: Colors.green,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeButton({
    required BuildContext context,
    required String type,
    required String title,
    required Color color,
    required IconData icon,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        _showTransactionDialog(context, type);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => TransactionForm(type: type),
    );
  }

  void _showDetailedList(BuildContext context, List<Transaction> transactions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toutes les Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}