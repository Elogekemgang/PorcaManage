import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:porcamanage/pages/screen_manage.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'auth/login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          if (user == null) {
            return const Login();
          } else {
            // RÉCUPÈRE LE FirestoreService AVANT DE NAVIGUER
            final firestoreService = Provider.of<FirestoreService?>(context);

            if (firestoreService == null) {
              // Le service n'est pas encore prêt, attends
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Maintenant le service est prêt, on peut afficher ScreenManage
            return const ScreenManage();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Erreur de connexion. Veuillez réessayer.'),
            ),
          );
        }
      },
    );
  }
}