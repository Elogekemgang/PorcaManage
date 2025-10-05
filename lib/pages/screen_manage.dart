import 'package:flutter/material.dart';
import 'package:porcamanage/pages/profile.dart';
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
    ProfileScreen(),  // temp placeholder
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
            icon: Image.asset("assets/financial-profit.png",width: 25,),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: Image.asset("assets/earning.png",width: 25,),
            title: Text("Debts"),
            selectedColor: Colors.pink,
            unselectedColor: Colors.green
          ),
          SalomonBottomBarItem(
            icon: Image.asset("assets/pay.png",width: 25
              ,),
            title: Text("D & C"),
            selectedColor: Colors.orange,
              unselectedColor: Colors.green,
            activeIcon: Image.asset("assets/pay.png",width: 25,),

          ),SalomonBottomBarItem(
            icon: Image.asset("assets/artificial-intelligence.png",width: 25,),
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
