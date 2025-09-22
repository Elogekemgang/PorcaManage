import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Temps de connexion dépassé");
      });
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } on TimeoutException catch (_) {
      throw "Connexion trop lente. Vérifiez votre réseau.";
    } catch (_) {
      throw "Une erreur inconnue est survenue.";
    }
  }

  Future<String?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException("Temps de connexion dépassé");
      });

      await result.user?.sendEmailVerification();


      return result.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } on TimeoutException catch (_) {
      throw "Connexion trop lente. Vérifiez votre réseau.";
    } catch (_) {
      throw "Une erreur inconnue est survenue.";
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw "La déconnexion a pris trop de temps. Veuillez réessayer.";
    } on FirebaseAuthException catch (e) {
      throw "Erreur de déconnexion: ${_mapFirebaseAuthError(e)}";
    } catch (e) {
      throw "Impossible de se déconnecter. Erreur: $e";
    }
  }

  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (_) {
      throw "Impossible d'envoyer l'email de réinitialisation.";
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (_) {
      throw "Impossible d'envoyer l'email de vérification.";
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "L'adresse email est invalide.";
      case "user-disabled":
        return "Ce compte a été désactivé.";
      case "user-not-found":
        return "Aucun compte trouvé pour cet email.";
      case "wrong-password":
        return "Mot de passe incorrect.";
      case "email-already-in-use":
        return "Cet email est déjà utilisé.";
      case "weak-password":
        return "Le mot de passe est trop faible.";
      case "too-many-requests":
        return "Trop de tentatives. Réessayez plus tard.";
      case "network-request-failed":
        return "Vérifiez votre connexion internet.";
      default:
        return "Erreur : ${e.message}";
    }
  }

}
