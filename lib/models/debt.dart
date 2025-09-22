class Debt {
  String id;
  String title;
  double amount;
  DateTime date;
  DateTime dueDate;
  String type; // 'debt' (dette) ou 'credit' (créance)
  String status; // 'pending', 'paid', 'received'
  String person; // Personne concernée
  String description;

  Debt({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.dueDate,
    required this.type,
    this.status = 'pending',
    required this.person,
    required this.description,
  });

  factory Debt.fromMap(Map<String, dynamic> data, String id) {
    return Debt(
      id: id,
      title: data['title'],
      amount: data['amount'].toDouble(),
      date: DateTime.parse(data['date']),
      dueDate: DateTime.parse(data['dueDate']),
      type: data['type'],
      status: data['status'],
      person: data['person'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'type': type,
      'status': status,
      'person': person,
      'description': description,
    };
  }

  bool get isOverdue {
    return dueDate.isBefore(DateTime.now()) && status == 'pending';
  }

  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }
}