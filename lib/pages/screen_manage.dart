import 'package:flutter/material.dart';
import 'package:porcamanage/pages/transaction/transaction.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

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
    Center(child: Text("Profile Page")),  // temp placeholder
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index; // met à jour la barre quand on change de page
          });
        },
        children: pages,
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          _pageController.jumpToPage(i); // synchronise le PageView avec la barre
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text("Debts"),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
            selectedColor: Colors.orange,
          ),SalomonBottomBarItem(
            icon: Icon(Icons.chat),
            title: Text("Chat"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
