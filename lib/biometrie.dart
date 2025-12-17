import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:porcamanage/pages/auth_wrapper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _startAuth();
  }

  Future<void> _startAuth() async {
    await Future.delayed(const Duration(milliseconds: 300)); // UX smooth

    try {
      final bool canCheck = await _auth.canCheckBiometrics;

      if (!canCheck) {
        _exitApp();
        return;
      }

      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Accès sécurisé',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
          useErrorDialogs: false,
          sensitiveTransaction: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/authwrapper');
      } else {
        _exitApp();
      }
    } catch (_) {
      _exitApp();
    }
  }

  void _exitApp() {
    if (!mounted) return;

    setState(() => _loading = false);

    Future.delayed(const Duration(milliseconds: 800), () {
      SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _loading ? 1 : 0,
          duration: const Duration(milliseconds: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/earning.png',
                width: 110,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}
