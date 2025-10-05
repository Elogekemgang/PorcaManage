import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/debt.dart';
import '../../services/firestore_service.dart';

class DebtFormScreen extends StatefulWidget {
  final String type; // 'debt' or 'credit'
  final Debt? existingDebt;

  const DebtFormScreen({super.key, required this.type, this.existingDebt});

  @override
  State<DebtFormScreen> createState() => _DebtFormScreenState();
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

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final existingDebt = widget.existingDebt;
    if (existingDebt != null) {
      _titleController.text = existingDebt.title;
      _amountController.text = existingDebt.amount.toString();
      _personController.text = existingDebt.person;
      _descriptionController.text = existingDebt.description;
      _selectedDate = existingDebt.date;
      _selectedDueDate = existingDebt.dueDate;
      _selectedType = existingDebt.type;
      _selectedStatus = existingDebt.status;
    } else {
      _selectedType = widget.type;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? _selectedDueDate : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _getTypeColor(_selectedType),
              onPrimary: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _getTypeColor(_selectedType),
              ),
            ),
          ),
          child: child!,
        );
      },
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final debt = Debt(
        id: widget.existingDebt?.id ?? "",
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        dueDate: _selectedDueDate,
        type: _selectedType,
        status: _selectedStatus,
        person: _personController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      final firestoreService = Provider.of<FirestoreService>(context, listen: false);

      if (widget.existingDebt != null) {
        await firestoreService.updateDebt(debt);
      } else {
        await firestoreService.addDebt(debt);
      }

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackbar();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.existingDebt != null
                    ? '${_selectedType == 'debt' ? 'Dette' : 'Créance'} mise à jour avec succès!'
                    : '${_selectedType == 'debt' ? 'Dette' : 'Créance'} ajoutée avec succès!',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Erreur: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDebt != null;
    final typeColor = _getTypeColor(_selectedType);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: typeColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            isEditing
                ? 'Modifier ${_selectedType == 'debt' ? 'la dette' : 'la créance'}'
                : 'Nouvelle ${_selectedType == 'debt' ? 'dette' : 'créance'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: typeColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            if (isEditing)
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: _showDeleteDialog,
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // En-tête visuel
                _buildHeader(isEditing),
                SizedBox(height: 24),

                // Type de transaction (seulement pour nouvelle création)
                if (!isEditing && widget.type.isEmpty)
                  _buildTypeSelector(),

                // Champs du formulaire
                _buildFormFields(),

                // Bouton de soumission
                SizedBox(height: 24),
                _buildSubmitButton(isEditing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    final typeColor = _getTypeColor(_selectedType);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withOpacity(0.9),
            typeColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(_selectedType),
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Modification' : 'Nouvelle entrée',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _selectedType == 'debt' ? 'Dette (je dois)' : 'Créance (on me doit)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type de transaction',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  value: 'debt',
                  title: 'Dette',
                  subtitle: 'Je dois de l\'argent',
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTypeOption(
                  value: 'credit',
                  title: 'Créance',
                  subtitle: 'On me doit de l\'argent',
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == value;

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedType = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
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
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Titre',
            hintText: 'Ex: Prêt voiture, Avance salaire...',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer un titre';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _amountController,
            label: 'Montant (FCFA)',
            hintText: '0.00',
            icon: Icons.attach_money,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un montant';
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Veuillez entrer un nombre valide';
              }
              if (amount <= 0) {
                return 'Le montant doit être supérieur à 0';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _personController,
            label: 'Personne concernée',
            hintText: 'Ex: Eloge kemgang, Société ABC...',
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16),
          _buildDateFields(),
          SizedBox(height: 16),
          if (widget.existingDebt != null) _buildStatusField(),
          SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description (optionnelle)',
            hintText: 'Notes supplémentaires...',
            icon: Icons.description,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _getTypeColor(_selectedType)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }

  Widget _buildDateFields() {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isOverdue = _selectedDueDate.isBefore(DateTime.now());

    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            label: 'Date de création',
            date: _selectedDate,
            formatter: dateFormat,
            onTap: () => _selectDate(context, false),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildDateButton(
            label: 'Échéance',
            date: _selectedDueDate,
            formatter: dateFormat,
            onTap: () => _selectDate(context, true),
            isWarning: isOverdue,
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required DateFormat formatter,
    required VoidCallback onTap,
    bool isWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 6),
        Material(
          color: isWarning ? Colors.red[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isWarning ? Colors.red[300]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: isWarning ? Colors.red : Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formatter.format(date),
                      style: TextStyle(
                        color: isWarning ? Colors.red : Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isWarning ? Colors.red : Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
              items: [
                DropdownMenuItem(
                  value: 'pending',
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('En attente'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: _selectedType == 'debt' ? 'paid' : 'received',
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(_selectedType == 'debt' ? 'Remboursé' : 'Reçu'),
                    ],
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTypeColor(_selectedType),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          isEditing ? 'Mettre à jour' : 'Créer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette ${_selectedType == 'debt' ? 'dette' : 'créance'} ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDebt();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _deleteDebt() {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    firestoreService.deleteDebt(widget.existingDebt!.id);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedType == 'debt' ? 'Dette' : 'Créance'} supprimée avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getTypeColor(String type) {
    return type == 'debt' ? Colors.red : Colors.green;
  }

  IconData _getTypeIcon(String type) {
    return type == 'debt' ? Icons.arrow_upward : Icons.arrow_downward;
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