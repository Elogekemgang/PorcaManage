import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/debt.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final VoidCallback onEdit;

  const DebtCard({
    super.key,
    required this.debt,
    required this.onDelete,
    required this.onUpdate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: InkWell(
          onTap: () => _showDebtDetails(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 12),
                _buildMainInfo(),
                SizedBox(height: 12),
                _buildStatusAndDueDate(),
                SizedBox(height: 12),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor(debt.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(debt.type),
            color: _getTypeColor(debt.type),
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                debt.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (debt.person.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  'avec ${debt.person}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: () {}, // Empêche la propagation du tap
          child: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[500]),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Modifier'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Montant',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text(
                '${debt.amount.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getTypeColor(debt.type),
                ),
              ),
            ],
          ),
          if (debt.daysUntilDue != 0) ...[
            Container(width: 1, height: 40, color: Colors.grey[300]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(debt.isOverdue ? 'Retard' : 'Jours restants',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text(
                  debt.isOverdue ? '${debt.daysUntilDue.abs()}j' : '${debt.daysUntilDue}j',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: debt.isOverdue ? Colors.red : Colors.green),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusAndDueDate() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(debt.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor(debt.status).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: _getStatusColor(debt.status), shape: BoxShape.circle)),
              SizedBox(width: 6),
              Text(_getStatusText(debt.status, debt.type),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getStatusColor(debt.status))),
            ],
          ),
        ),
        Spacer(),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
            SizedBox(width: 4),
            Text(
              _formatDateSafe(debt.dueDate, 'dd/MM/yyyy'),
              style: TextStyle(
                  fontSize: 12,
                  color: debt.isOverdue ? Colors.red : Colors.grey[600],
                  fontWeight: debt.isOverdue ? FontWeight.w600 : FontWeight.normal),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActionButtons() {
    if (debt.status != 'pending') return SizedBox.shrink();
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: Icon(Icons.edit, size: 16),
            label: Text('Modifier'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onUpdate,
            icon: Icon(debt.type == 'debt' ? Icons.check_circle : Icons.attach_money, size: 16),
            label: Text(debt.type == 'debt' ? 'Marquer payé' : 'Marquer reçu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTypeColor(debt.type),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        )
      ],
    );
  }

  void _showDebtDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)
                  )
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _getTypeColor(debt.type).withOpacity(0.1),
                      shape: BoxShape.circle
                  ),
                  child: Icon(
                      _getTypeIcon(debt.type),
                      color: _getTypeColor(debt.type),
                      size: 24
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          debt.title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      if (debt.person.isNotEmpty)
                        Text(
                            'Avec ${debt.person}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600])
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDetailItem('Montant', '${debt.amount.toStringAsFixed(0)} FCFA'),
            _buildDetailItem('Date de création', _formatDateSafe(debt.date, 'dd/MM/yyyy')),
            _buildDetailItem('Échéance', _formatDateSafe(debt.dueDate, 'dd/MM/yyyy')),
            _buildDetailItem('Statut', _getStatusText(debt.status, debt.type)),
            if (debt.description.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                  'Description',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]
                  )
              ),
              SizedBox(height: 8),
              Text(
                  debt.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])
              ),
            ],
            SizedBox(height: 20),
            if (debt.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit();
                      },
                      style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12)
                      ),
                      child: Text('Modifier'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onUpdate();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _getTypeColor(debt.type),
                          padding: EdgeInsets.symmetric(vertical: 12)
                      ),
                      child: Text(
                          debt.type == 'debt' ? 'Marquer payé' : 'Marquer reçu'
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
              '$label: ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]
              )
          ),
          Expanded(
            child: Text(
                value,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.right
            ),
          ),
        ],
      ),
    );
  }

  // Méthode sécurisée pour formater les dates
  String _formatDateSafe(DateTime date, String format) {
    try {
      return DateFormat(format, 'fr_FR').format(date);
    } catch (e) {
      // Fallback si le formatage échoue
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
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
}