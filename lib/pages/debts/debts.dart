import 'package:flutter/material.dart';
import 'package:porcamanage/customers/colors.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../customers/custom_app_bar.dart';
import '../../models/debt.dart';
import '../../services/firestore_service.dart';
import '../widget/debt_card.dart';
import 'debt_form_screen.dart';

class Debts extends StatelessWidget {
  const Debts({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            "Dettes & Créances",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          bottom: TabBar(
            indicatorColor: Colors.yellow[700],
            indicatorWeight: 3,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.w600,color: Colors.yellow[700],),
            tabs: [
              Tab(
                icon: Icon(Icons.arrow_upward, size: 20),
                text: 'Dettes',
              ),
              Tab(
                icon: Icon(Icons.arrow_downward, size: 20),
                text: 'Créances',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDebtsTab(context, 'debt'),
            _buildDebtsTab(context, 'credit'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showDebtTypeMenu(context),
          backgroundColor: Colors.yellow[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Row(
            spacing: 10,
            children: [
              Icon(Icons.add, color:AppColors.primary),
              Text("nouvelle dette",style: TextStyle(fontSize: 15,color: AppColors.primary),)
            ],
          ),
        ),
      ),
    );
  }

  void _showDebtTypeMenu(BuildContext context) {
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
              'Nouvelle Entrée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDebtTypeButton(
                    context: context,
                    type: 'debt',
                    title: 'Nouvelle Dette',
                    subtitle: 'Je dois de l\'argent',
                    color: Colors.red,
                    icon: Icons.arrow_upward,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDebtTypeButton(
                    context: context,
                    type: 'credit',
                    title: 'Nouvelle Créance',
                    subtitle: 'On me doit de l\'argent',
                    color: Colors.green,
                    icon: Icons.arrow_downward,
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

  Widget _buildDebtTypeButton({
    required BuildContext context,
    required String type,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DebtFormScreen(type: type),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, isDebt);
        }

        final debts = snapshot.data!;
        return _buildDebtsContent(context, debts, isDebt);
      },
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
            'Chargement...',
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

  Widget _buildEmptyState(BuildContext context, bool isDebt) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDebt ? Icons.credit_card_off : Icons.money_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              isDebt ? 'Aucune dette' : 'Aucune créance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              isDebt
                  ? 'Ajoutez vos premières dettes pour commencer le suivi'
                  : 'Ajoutez vos premières créances pour commencer le suivi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showDebtTypeMenu(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(isDebt ? 'Ajouter une dette' : 'Ajouter une créance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtsContent(BuildContext context, List<Debt> debts, bool isDebt) {
    final totalAmount = debts.fold(0.0, (sum, debt) => sum + debt.amount);
    final pendingDebts = debts.where((debt) => debt.status == 'pending').toList();
    final overdueDebts = debts.where((debt) => debt.isOverdue).toList();
    final recentDebts = debts.take(5).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header avec résumé
          _buildSummaryHeader(totalAmount, pendingDebts.length, overdueDebts.length, isDebt),

          SizedBox(height: 24),

          // Actions rapides
          _buildQuickActions(context, isDebt),

          SizedBox(height: 24),

          // Liste des dettes/créances récentes
          _buildRecentDebtsSection(context, recentDebts, isDebt),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(double totalAmount, int pendingCount, int overdueCount, bool isDebt) {
    final color = isDebt ? Colors.red : Colors.green;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isDebt ? 'Total des Dettes' : 'Total des Créances',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${totalAmount.toStringAsFixed(2)} FCFA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat('En attente', pendingCount, Icons.pending),
              _buildSummaryStat('En retard', overdueCount, Icons.warning),
              _buildSummaryStat('Total', pendingCount, Icons.list),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String title, int count, IconData icon) {
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
          count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDebt) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: isDebt ? 'Ajouter Dette' : 'Ajouter Créance',
            subtitle: 'Nouvelle entrée',
            icon: Icons.add,
            color: Colors.yellow[700]!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DebtFormScreen(type: isDebt ? 'debt' : 'credit',),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            title: 'Voir Tout',
            subtitle: 'Liste complète',
            icon: Icons.list_alt,
            color: Colors.blue,
            onTap: () => _showAllDebts(context, isDebt),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentDebtsSection(BuildContext context, List<Debt> recentDebts, bool isDebt) {
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
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Colors.yellow[700],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${isDebt ? 'Dettes' : 'Créances'} Récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            if (recentDebts.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  isDebt ? 'Aucune dette récente' : 'Aucune créance récente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...recentDebts.map((debt) => DebtCard(
                debt: debt,
                onDelete: () => _deleteDebt(context, debt),
                onUpdate: () => _updateDebtStatus(context, debt),
                onEdit: () => _editDebt(context, debt),
              )),
          ],
        ),
      ),
    );
  }

  void _showAllDebts(BuildContext context, bool isDebt) {
    // Implémentation pour afficher toutes les dettes/créances
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
        builder: (context) => DebtFormScreen(existingDebt: debt, type: debt.type),
      ),
    );
  }
}