import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static Future<void> saveCart(List cartItems) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('cart_$_uid', jsonEncode(cartItems));
  }

  static Future<List> loadCart() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('cart_$_uid');

    if (data == null) return [];

    return jsonDecode(data);
  }

  static Future<void> saveWishlist(List wishlistItems) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('wishlist_$_uid', jsonEncode(wishlistItems));
  }

  static Future<List> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('wishlist_$_uid');

    if (data == null) return [];

    return jsonDecode(data);
  }
}
