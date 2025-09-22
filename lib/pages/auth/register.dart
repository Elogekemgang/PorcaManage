import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../customers/colors.dart';
import '../../customers/custom_buttom.dart';
import '../../customers/custom_input.dart';
import '../../customers/loading_indicator.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'custom_input_auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userService = Provider.of<UserService>(context, listen: false);
      final emailExists = await userService.checkEmailExists(_emailController.text.trim());
      if (emailExists) {
        throw "Cet email est déjà utilisé par un autre compte";
      }
      final userId = await authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (userId == null) {
        throw "Erreur lors de la création du compte";
      }
      final newUser = UserModel(
        id: userId,
        name: _emailController.text.split('@')[0],
        email: _emailController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userService.createUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie ! Un email de vérification a été envoyé.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      Navigator.pushReplacementNamed(context, '/authwrapper');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'inscription: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingIndicator(message: "Création du compte...")
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset("assets/logo/logoff.png", width: 200),
              const SizedBox(height: 25),
              Text(
                "Inscription",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Remplissez les informations ci-dessous pour créer votre compte",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Champ Nom
              CustomInput(
                label: "Nom complet",
                hintext: "Entrer votre nom complet",
                prefixIcon: Icons.person,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  if (value.length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Champ Email
              CustomInput(
                label: "Email",
                hintext: "Entrer votre adresse email",
                prefixIcon: Icons.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              CustomInputAuth(
                label: "Mot de passe",
                hintext: "Entrer votre mot de passe",
                prefixIcon: Icons.lock,
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: _obscurePassword
                      ? Icon(Icons.visibility, color: AppColors.primary)
                      : Icon(Icons.visibility_off, color: AppColors.primary),
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
              const SizedBox(height: 15),

              // Champ Confirmation mot de passe
              CustomInputAuth(
                label: "Confirmer le mot de passe",
                hintext: "Confirmer votre mot de passe",
                prefixIcon: Icons.lock_outline,
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: _obscureConfirmPassword
                      ? Icon(Icons.visibility, color: AppColors.primary)
                      : Icon(Icons.visibility_off, color: AppColors.primary),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Checkbox conditions
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() => _isChecked = value ?? false);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Naviguer vers les conditions d'utilisation
                      },
                      child: const Text(
                        "J'accepte les conditions d'utilisation et la politique de confidentialité",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Bouton d'inscription
              CustomButton(
                label: "S'inscrire",
                action: _register,
                background: AppColors.primary,
                large: 0.9,
              ),
              const SizedBox(height: 20),

              // Lien vers connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Déjà un compte ? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      "Se connecter",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}