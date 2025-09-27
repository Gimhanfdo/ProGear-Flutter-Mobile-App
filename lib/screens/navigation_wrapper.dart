import 'package:flutter/material.dart';
import 'package:progear_mobileapp/screens/cart.dart';
import 'package:progear_mobileapp/screens/home.dart';
import 'package:progear_mobileapp/screens/news.dart';
import 'package:progear_mobileapp/screens/products.dart';
import 'package:progear_mobileapp/screens/shared/bottom_nav_bar.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int currentIndex = 0;

  List<Widget> pages = [
    const Home(),
    const ProductsPage(),
    const CartPage(),
    NewsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
