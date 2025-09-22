import 'package:flutter/material.dart';

class Category {
  String id;
  String name;
  String type; // 'income' or 'expense'
  String icon; // Nom de l'icône
  Color color;
  double budget; // Budget mensuel optionnel

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon = 'receipt',
    this.color = Colors.blue,
    this.budget = 0,
  });

  factory Category.fromMap(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'],
      type: data['type'],
      icon: data['icon'] ?? 'receipt',
      color: Color(data['color']),
      budget: data['budget']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color.value,
      'budget': budget,
    };
  }

  // Méthode pour obtenir les catégories prédéfinies
  static List<Category> getDefaultCategories() {
    return [
      // Catégories de dépenses
      Category(
        name: 'Nutrition',
        type: 'expense',
        icon: 'restaurant',
        color: Colors.red, id: '',
      ),
      Category(
        name: 'Transport',
        type: 'expense',
        icon: 'directions_car',
        color: Colors.blue, id: '',
      ),
      Category(
        name: 'Internet',
        type: 'expense',
        icon: 'wifi',
        color: Colors.purple, id: '',
      ),
      Category(
        name: 'Loyer',
        type: 'expense',
        icon: 'home',
        color: Colors.brown, id: '',
      ),
      Category(
        name: 'Loisir',
        type: 'expense',
        icon: 'sports_esports',
        color: Colors.orange, id: '',
      ),
      Category(
        name: 'Santé',
        type: 'expense',
        icon: 'local_hospital',
        color: Colors.green, id: '',
      ),
      Category(
        name: 'Éducation',
        type: 'expense',
        icon: 'school',
        color: Colors.indigo, id: '',
      ),
      Category(
        name: 'Shopping',
        type: 'expense',
        icon: 'shopping_cart',
        color: Colors.pink, id: '',
      ),

      // Catégories de revenus
      Category(
        name: 'Salaire',
        type: 'income',
        icon: 'work',
        color: Colors.green, id: '',
      ),
      Category(
        name: 'Cadeau',
        type: 'income',
        icon: 'card_giftcard',
        color: Colors.blue, id: '',
      ),
      Category(
        name: 'Vente',
        type: 'income',
        icon: 'attach_money',
        color: Colors.orange, id: '',
      ),
      Category(
        name: 'Investissement',
        type: 'income',
        icon: 'trending_up',
        color: Colors.purple, id: '',
      ),
      Category(
        name: 'Prime',
        type: 'income',
        icon: 'star',
        color: Colors.amber, id: '',
      ),
    ];
  }

  // Méthode pour obtenir l'icône correspondante
  IconData getIconData() {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'wifi':
        return Icons.wifi;
      case 'home':
        return Icons.home;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'work':
        return Icons.work;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'trending_up':
        return Icons.trending_up;
      case 'star':
        return Icons.star;
      default:
        return Icons.receipt;
    }
  }
}