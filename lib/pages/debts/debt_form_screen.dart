import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/debt.dart';
import '../../services/firestore_service.dart';

class DebtFormScreen extends StatefulWidget {
  final String type; // 'debt' or 'credit'
  final Debt existingDebt;

  const DebtFormScreen({super.key,  required this.type, required this.existingDebt});

  @override
  _DebtFormScreenState createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends State<DebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _personController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDueDate = DateTime.now().add(Duration(days: 30));
  String _selectedType = 'debt';
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();

    // Si on édite une dette existante, pré-remplir les champs
    if (widget.existingDebt != null) {
      _titleController.text = widget.existingDebt.title;
      _amountController.text = widget.existingDebt.amount.toString();
      _personController.text = widget.existingDebt.person ?? '';
      _descriptionController.text = widget.existingDebt.description ?? '';
      _selectedDate = widget.existingDebt.date;
      _selectedDueDate = widget.existingDebt.dueDate;
      _selectedType = widget.existingDebt.type;
      _selectedStatus = widget.existingDebt.status;
    } else if (widget.type != null) {
      _selectedType = widget.type;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? _selectedDueDate : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _selectedDueDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final debt = Debt(
        id: widget.existingDebt.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        dueDate: _selectedDueDate,
        type: _selectedType,
        status: _selectedStatus,
        person: _personController.text,
        description:_descriptionController.text
      );

      final firestoreService = Provider.of<FirestoreService>(context, listen: false);

      if (widget.existingDebt != null) {
        firestoreService.updateDebt(debt);
      } else {
        firestoreService.addDebt(debt);
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              widget.existingDebt != null
                  ? '${_selectedType == 'debt' ? 'Dette' : 'Créance'} mise à jour avec succès!'
                  : '${_selectedType == 'debt' ? 'Dette' : 'Créance'} ajoutée avec succès!'
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDebt != null;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditing
                ? 'Modifier ${_selectedType == 'debt' ? 'la dette' : 'la créance'}'
                : 'Nouvelle ${_selectedType == 'debt' ? 'dette' : 'créance'}'
        ),
        backgroundColor: _selectedType == 'debt' ? Colors.red : Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!isEditing && widget.type == null)
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'debt',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Dette (je dois)'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'credit',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Créance (on me doit)'),
                          ],
                        ),
                      ),
                    ], onChanged: (String? value) {  },
                    /*onChanged: (String newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },*/
                  ),
                if (!isEditing && widget.type == null) SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Montant (€)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer un montant';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: _personController,
                  decoration: InputDecoration(
                    labelText: 'Personne concernée',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date de création'),
                          SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () => _selectDate(context, false),
                            child: Text(dateFormat.format(_selectedDate)),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date d\'échéance'),
                          SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () => _selectDate(context, true),
                            child: Text(dateFormat.format(_selectedDueDate)),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: _selectedDueDate.isBefore(DateTime.now())
                                  ? Colors.red[300]
                                  : Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                if (isEditing)
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('En attente'),
                      ),
                      DropdownMenuItem(
                        value: _selectedType == 'debt' ? 'paid' : 'received',
                        child: Text(_selectedType == 'debt' ? 'Remboursé' : 'Reçu'),
                      ),
                    ], onChanged: (String? value) {  },
                    /*onChanged: (String newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },*/
                  ),
                if (isEditing) SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optionnelle)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'debt' ? Colors.red : Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _personController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}