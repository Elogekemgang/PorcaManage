import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/debt.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final Function onDelete;
  final Function onUpdate;

  const DebtCard({super.key, required this.debt, required this.onDelete, required this.onUpdate, void Function()? onEdit});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'received':
        return Colors.green;
      case 'pending':
        return debt.isOverdue ? Colors.red : Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status, String type) {
    switch (status) {
      case 'paid':
        return type == 'debt' ? 'Remboursé' : 'Reçu';
      case 'received':
        return 'Reçu';
      case 'pending':
        return type == 'debt' ? 'À rembourser' : 'À recevoir';
      default:
        return 'Inconnu';
    }
  }

  IconData _getTypeIcon(String type) {
    return type == 'debt' ? Icons.arrow_upward : Icons.arrow_downward;
  }

  Color _getTypeColor(String type) {
    return type == 'debt' ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    debt.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _getTypeIcon(debt.type),
                  color: _getTypeColor(debt.type),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Montant: ${currencyFormat.format(debt.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            if (debt.person.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Personne: ${debt.person}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            Text(
              'Échéance: ${dateFormat.format(debt.dueDate)}',
              style: TextStyle(
                fontSize: 14,
                color: debt.isOverdue ? Colors.red : null,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(debt.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getStatusColor(debt.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(debt.status, debt.type),
                    style: TextStyle(
                      color: _getStatusColor(debt.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (debt.isOverdue)
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'En retard!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (debt.status == 'pending')
                  ElevatedButton(
                    onPressed: () => onUpdate(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getTypeColor(debt.type),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      debt.type == 'debt' ? 'Marquer payé' : 'Marquer reçu',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}