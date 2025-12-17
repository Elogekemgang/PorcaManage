import 'package:flutter/material.dart';
import 'package:porcamanage/pages/profile.dart';
import 'package:porcamanage/pages/transaction/transaction.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:porcamanage/services/firestore_service.dart';

import 'chat/chat.dart';
import 'debts/debts.dart';
import 'home/home.dart';

class ScreenManage extends StatefulWidget {
  const ScreenManage({super.key});

  @override
  State<ScreenManage> createState() => _ScreenManageState();
}

class _ScreenManageState extends State<ScreenManage> {
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> pages = [
    Home(),
    Transactions(),
    Debts(),
    ChatBotPage(),
    ProfileScreen(),
  ];

  int _currentIndex = 0;
  bool _isLoading = true; // Renommé pour plus de clarté

  @override
  void initState() {
    super.initState();
    _checkFirestoreService();
  }

  void _checkFirestoreService() {
    // Vérifie que FirestoreService est disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firestoreService = Provider.of<FirestoreService?>(context, listen: false);

      if (firestoreService != null) {
        setState(() {
          _isLoading = false;
        });
      } else {
        // Si pas disponible, attendre un peu et réessayer
        Future.delayed(const Duration(milliseconds: 100), _checkFirestoreService);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Vérification finale
    final firestoreService = Provider.of<FirestoreService?>(context);

    if (firestoreService == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          _pageController.jumpToPage(i);
        },
        items: [
          SalomonBottomBarItem(
            icon: Image.asset("assets/financial-profit.png", width: 25),
            title: const Text("Accueil"),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: Image.asset("assets/earning.png", width: 25),
            title: const Text("Transactions"),
            selectedColor: Colors.pink,
            unselectedColor: Colors.green,
          ),
          SalomonBottomBarItem(
            icon: Image.asset("assets/pay.png", width: 25),
            title: const Text("D & C"),
            selectedColor: Colors.orange,
            unselectedColor: Colors.green,
          ),
          SalomonBottomBarItem(
            icon: Image.asset("assets/artificial-intelligence.png", width: 25),
            title: const Text("Chat"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person, color: Colors.teal),
            title: const Text("Profile"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}