import 'package:flutter/material.dart';

import 'home_page.dart';
import 'drink_page.dart';
import 'food_page.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onMapTap;

  const MainNavigationScreen({
    super.key,
    required this.onMenuTap,
    required this.onMapTap,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {

  int index = 0;

  final pages = [
    const HomePage(),
    const DrinkPage(),
    const FoodPage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,

        onTap: (i) {
          setState(() {
            index = i;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar),
            label: "Drink",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Food",
          ),

        ],
      ),
    );
  }
}