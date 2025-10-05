import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:porcamanage/pages/auth/register.dart';
import 'package:porcamanage/pages/auth_wrapper.dart';
import 'package:porcamanage/pages/onboarding_screen.dart';
import 'package:porcamanage/services/auth_service.dart';
import 'package:porcamanage/services/firestore_service.dart';
import 'package:porcamanage/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:porcamanage/pages/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  // Initialise les locales
  await initializeDateFormatting('fr_FR',null);

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserService>(create: (_) => UserService()),

        // 🔥 Écoute le user connecté
        StreamProvider<User?>(
          create: (_) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),

        // 🔥 FirestoreService dépend du user
        ProxyProvider<User?, FirestoreService?>(
          update: (_, user, __) =>
          user != null ? FirestoreService(user.uid) : null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PorcaManage',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: seenOnboarding ? const AuthWrapper() : const OnboardingScreen(),
        routes: {
          '/login': (context) => const Login(),
          '/register': (context) => const Register(),
          '/authwrapper': (context) => const AuthWrapper(),
        },
      ),
    );
  }
}
