import 'package:flutter/material.dart';
import 'colors.dart'; // adapte le chemin si besoin

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double radius;

  const CustomAppBar({
    super.key,
    required this.title,
    this.radius = 24, // valeur par défaut pour les coins arrondis
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          ),
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent, // évite le conflit de couleur
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
