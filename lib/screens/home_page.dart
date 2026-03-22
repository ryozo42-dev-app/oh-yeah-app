import 'package:flutter/material.dart';
import 'drink_page.dart';
import 'food_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int currentIndex = 0;

  final pages = [
    const DrinkPage(),
    const FoodPage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("MENU"),
      ),

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

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