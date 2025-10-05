import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../models/debt.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final String userId;
  final ImagePicker _imagePicker = ImagePicker();


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

  // Profil utilisateur
  CollectionReference get userProfileCollection =>
      FirebaseFirestore.instance.collection('users/$userId/profile');

  Future<UserProfile?> getUserProfile() async {
    try {
      final doc = await userProfileCollection.doc('userData').get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erreur getProfile: $e');
      return null;
    }
  }

  Future<void> createUserProfile(UserProfile profile) async {
    return userProfileCollection.doc('userData').set(profile.toMap());
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    return userProfileCollection.doc('userData').update(profile.toMap());
  }

  // Statistiques utilisateur - VERSION CORRIGÉE
  Stream<Map<String, dynamic>> getUserStats() {
    return transactionsCollection.snapshots().asyncMap((transactionSnapshot) async {
      final debtsSnapshot = await debtsCollection.get();

      final transactions = transactionSnapshot.docs.length;
      final debts = debtsSnapshot.docs.length;

      // Calcul des économies (revenus - dépenses)
      double totalIncome = 0;
      double totalExpense = 0;

      for (var doc in transactionSnapshot.docs) {
        final transaction = Transaction.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      final savings = totalIncome - totalExpense;

      return {
        'totalTransactions': transactions,
        'totalDebts': debts,
        'totalSavings': savings > 0 ? savings.toStringAsFixed(0) : '0',
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
      };
    });
  }

  // Alternative plus simple si la version asyncMap pose problème
  Stream<Map<String, dynamic>> getUserStatsSimple() {
    return transactionsCollection.snapshots().map((snapshot) {
      int totalTransactions = snapshot.docs.length;
      double totalIncome = 0;
      double totalExpense = 0;

      for (var doc in snapshot.docs) {
        final transaction = Transaction.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      final savings = totalIncome - totalExpense;

      return {
        'totalTransactions': totalTransactions,
        'totalDebts': 0, // À implémenter si besoin
        'totalSavings': savings > 0 ? savings.toStringAsFixed(0) : '0',
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
      };
    });
  }

  // Méthode pour mettre à jour la photo de profil
  Future<void> updateProfilePicture(String base64Image) async {
    try {
      await userProfileCollection.doc('userData').update({
        'profilePicture': base64Image,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur mise à jour photo: $e');
      throw e;
    }
  }

  // Méthode pour sélectionner une image depuis la galerie
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        return await _cropAndConvertImage(image.path);
      }
      return null;
    } catch (e) {
      print('Erreur sélection image: $e');
      return null;
    }
  }

  // Méthode pour prendre une photo avec l'appareil
  Future<String?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        return await _cropAndConvertImage(image.path);
      }
      return null;
    } catch (e) {
      print('Erreur prise photo: $e');
      return null;
    }
  }

  // Méthode pour recadrer et convertir l'image en base64
  Future<String?> _cropAndConvertImage(String imagePath) async {
    try {
      // Recadrage de l'image
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer la photo',
            toolbarColor: Colors.yellow[700]!,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recadrer la photo',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        // Lecture et conversion en base64
        final bytes = await File(croppedFile.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        return base64Image;
      }
      return null;
    } catch (e) {
      print('Erreur conversion image: $e');
      return null;
    }
  }

  // Méthode pour supprimer la photo de profil
  Future<void> removeProfilePicture() async {
    try {
      await userProfileCollection.doc('userData').update({
        'profilePicture': FieldValue.delete(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur suppression photo: $e');
      throw e;
    }
  }

  // Méthode pour obtenir l'URL de la photo (pour l'affichage)
  String? getProfilePictureUrl(UserProfile? profile) {
    if (profile?.profilePicture != null) {
      return profile!.profilePicture;
    }
    return null;
  }

}