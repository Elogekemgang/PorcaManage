import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:porcamanage/pages/auth/register.dart';
import 'package:porcamanage/pages/auth_wrapper.dart';
import 'package:porcamanage/pages/onboarding_screen.dart';
import 'package:porcamanage/services/auth_service.dart';
import 'package:porcamanage/services/firestore_service.dart';
import 'package:porcamanage/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:porcamanage/pages/auth/login.dart';

void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  runApp(MyApp(seenOnboarding: seenOnboarding,));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<FirestoreService>(create: (_) => FirestoreService("userId")),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PorcaManage',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: seenOnboarding ? AuthWrapper() : OnboardingScreen(),
        //home: Login(),
        routes: {
          '/login': (context) => Login(),
          '/register': (context) => Register(),
          //'/home': (context) => Home(),
          //'/screenmanage': (context) => ScreenManage(),
          '/authwrapper': (context) => AuthWrapper(),
         // '/mes-annonces': (context) => MesAnnoncesPage(),
          //'/chat': (context) => ChatPage(),
        },
      ),
    );
  }
}