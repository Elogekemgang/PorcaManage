import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profession;
  final String? phone;
  final String? photoBase64;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profession,
    this.phone,
    this.photoBase64,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profession: data['profession'] ?? '',
      phone: data['phone'],
      photoBase64: data['photoBase64'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profession': profession,
      'phone': phone,
      'photoBase64': photoBase64,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? photoBase64,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      profession: profession ?? profession,
      email: email,
      photoBase64: photoBase64 ?? this.photoBase64,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }


  // Méthode statique pour récupérer l'utilisateur connecté
  static Future<UserModel?> getCurrentUser() async {
    try {
      final User? authUser = FirebaseAuth.instance.currentUser;

      if (authUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(authUser.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromMap(authUser.uid, userDoc.data() as Map<String, dynamic>);
        } else {
          // Créer un document utilisateur s'il n'existe pas encore
          return await _createUserDocument(authUser);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  // Méthode pour créer un document utilisateur s'il n'existe pas
  static Future<UserModel?> _createUserDocument(User authUser) async {
    try {
      final newUser = UserModel(
        id: authUser.uid,
        name: authUser.displayName ?? '',
        email: authUser.email ?? '',
        profession:'',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        phone: authUser.phoneNumber ?? "",
        photoBase64: authUser.photoURL ?? '',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .set(newUser.toMap());

      return newUser;
    } catch (e) {
      print('Erreur lors de la création du document utilisateur: $e');
      return null;
    }
  }
}