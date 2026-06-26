import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thrift_corner/core/storage/local_storage.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'package:thrift_corner/features/cart/screens/wishlist_items.dart';
import 'package:thrift_corner/features/auth/screens/login_screen.dart';
import 'package:thrift_corner/features/home/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final rawWishlist = await LocalStorage.loadWishlist();
        final rawCart = await LocalStorage.loadCart();

        wishlistItems = List<Map<dynamic, dynamic>>.from(rawWishlist);
        cartItems = List<Map<dynamic, dynamic>>.from(rawCart);
      }

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 7),
          child: Image.asset('assets/logo/full_name.png', width: 400),
        ),
      ),
    );
  }
}
