import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../models/debt.dart';

class FirestoreService {
  final String userId;

  FirestoreService(this.userId);

  // Collection references
  CollectionReference get transactionsCollection =>
      FirebaseFirestore.instance.collection('users/$userId/transactions');

  CollectionReference get debtsCollection =>
      FirebaseFirestore.instance.collection('users/$userId/debts');

  // Transactions methods
  Stream<List<Transaction>> getTransactions() {
    return transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addTransaction(Transaction transaction) {
    return transactionsCollection.add(transaction.toMap());
  }

  Future<void> updateTransaction(Transaction transaction) {
    return transactionsCollection
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) {
    return transactionsCollection.doc(id).delete();
  }

  // Debts methods
  Stream<List<Debt>> getDebts() {
    return debtsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Debt.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Stream<List<Debt>> getDebtsByType(String type) {
    return debtsCollection
        .where('type', isEqualTo: type)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Debt.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addDebt(Debt debt) {
    return debtsCollection.add(debt.toMap());
  }

  Future<void> updateDebt(Debt debt) {
    return debtsCollection.doc(debt.id).update(debt.toMap());
  }

  Future<void> deleteDebt(String id) {
    return debtsCollection.doc(id).delete();
  }

  // Méthodes pour les catégories
  CollectionReference get categoriesCollection =>
      FirebaseFirestore.instance.collection('users/$userId/categories');

  Stream<List<Category>> getCategories() {
    return categoriesCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addCategory(Category category) {
    return categoriesCollection.add(category.toMap());
  }

  Future<void> updateCategory(Category category) {
    return categoriesCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) {
    return categoriesCollection.doc(id).delete();
  }

  // Méthode pour initialiser les catégories par défaut
  Future<void> initializeDefaultCategories() async {
    final categoriesSnapshot = await categoriesCollection.get();
    if (categoriesSnapshot.docs.isEmpty) {
      final defaultCategories = Category.getDefaultCategories();
      for (var category in defaultCategories) {
        await addCategory(category);
      }
    }
  }
}