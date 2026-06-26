import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thrift_corner/core/utils/snackbar_helper.dart';
import 'package:thrift_corner/features/auth/screens/login_screen.dart';
import 'package:thrift_corner/features/home/screens/cart_screen.dart';
import 'package:thrift_corner/features/home/screens/category_screen.dart';
import 'package:thrift_corner/features/home/screens/wishlist_screen.dart';
import 'package:thrift_corner/features/profile/screens/profile_screen.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'package:thrift_corner/features/cart/screens/wishlist_items.dart';

class AppDrawer extends StatelessWidget {
  final Future<void> Function() onWishlistChanged;

  const AppDrawer({super.key, required this.onWishlistChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      width: 75,
                      height: 75,
                    ),
                  ),

                  const SizedBox(width: 0),

                  Expanded(
                    child: Image.asset(
                      'assets/logo/full_name.png',
                      height: 400,

                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Categories'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Wishlist'),
              trailing: wishlistItems.isEmpty
                  ? null
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${wishlistItems.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );

                await onWishlistChanged();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('Cart'),
              trailing: cartItems.isEmpty
                  ? null
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${cartItems.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                "Find. Love. Thrift.",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                try {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    SnackbarHelper.showSuccess(
                      context,
                      'Logged out successfully',
                    );
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (context.mounted) {
                    SnackbarHelper.showError(context, e.code);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
