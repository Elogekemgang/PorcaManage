import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../customers/colors.dart';
import '../../customers/custom_buttom.dart';
import '../../customers/custom_input.dart';
import '../../customers/loading_indicator.dart';
import '../../services/auth_service.dart';
import 'custom_input_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/screenmanage');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
        body: _isLoading ? LoadingIndicator(message: "Connexion en cours...") :
        SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Form(
              key: _formKey,
              child:
              Column(
                children: [
                  SizedBox(height: 100,),
                  Image.asset("assets/logo/logoff.png",width: 200,),
                  SizedBox(height: 25,),
                  /*Text("MboaLink",
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,color: Color(0xFF2EC4B6),
            ),
            ),*/
                  SizedBox(height: 20,),
                  Text("Connexion",
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                    ),
                  ),
                  //SizedBox(height: 20,),
                  Text("Connecter vous à votre compte pour continuer",textAlign: TextAlign.center,),
                  SizedBox(height: 20,),
                  CustomInput(
                    label: "Email",
                    hintext: "Entrer l'adresse email",
                    prefixIcon: Icons.person,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un email';
                      }
                      if (!value.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20,),

                  CustomInputAuth(
                    label: "Password",
                    hintext: "Entrer le mot de passe",
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: _obscurePassword ? Icon(Icons.visibility,color: AppColors.primary,) : Icon(Icons.visibility_off,color: AppColors.primary,),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit avoir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20,),

                  CustomButton(
                      label: "Se connecter",
                      action: _login,
                      background: AppColors.primary,
                      large: 0.9
                  ),

                  SizedBox(height: 40,),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[600],thickness: 1.5,)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ou continuer avec',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[600],thickness: 1.5)),
                    ],
                  ),
                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.outlined(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/icons/Google.png',
                          width: 30,
                        ),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton.outlined(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          'assets/icons/Facebook.svg',
                          width: 30,
                        ),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ],
                  )
                  ,SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Vous n'avez pas de compte ?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            )
        )

    );
  }
}