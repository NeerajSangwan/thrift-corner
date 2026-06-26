import 'package:flutter/material.dart';
import 'package:thrift_corner/features/home/screens/category_screen.dart';
import 'package:thrift_corner/features/home/screens/home_screen.dart';
import 'package:thrift_corner/features/home/screens/wishlist_screen.dart';
import 'package:thrift_corner/features/profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CategoryScreen();
      case 2:
        return const WishlistScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          setState(() => currentIndex = 0);
        }
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: (value) => setState(() => currentIndex = value),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.crop_square_outlined),
              label: 'Category',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_rounded),
              label: 'Profile',
            ),
          ],
        ),
        body: _getScreen(currentIndex),
      ),
    );
  }
}
