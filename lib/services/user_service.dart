import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw "Erreur lors de la création de l'utilisateur: $e";
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw "Erreur lors de la récupération de l'utilisateur: $e";
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw "Erreur lors de la mise à jour de l'utilisateur: $e";
    }
  }

  Future<void> updateProfileImage(String userId, String imageBase64) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'photoBase64': imageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la photo: $e');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map(
          (doc) {
        if (doc.exists) {
          return UserModel.fromMap(doc.id, doc.data()!);
        }
        return null;
      },
    ).handleError((error) {
      print('Erreur stream utilisateur: $error');
      return null;
    });
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw "Erreur lors de la vérification de l'email: $e";
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw "Erreur lors de la suppression de l'utilisateur: $e";
    }
  }
}