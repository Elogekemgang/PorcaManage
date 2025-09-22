class Transaction {
  String id;
  String title;
  double amount;
  DateTime date;
  String category;
  String type; // 'income' or 'expense'

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });

  factory Transaction.fromMap(Map<String, dynamic> data, String id) {
    return Transaction(
      id: id,
      title: data['title'],
      amount: data['amount'].toDouble(),
      date: DateTime.parse(data['date']),
      category: data['category'],
      type: data['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type,
    };
  }
}