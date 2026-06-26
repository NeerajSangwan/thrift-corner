import 'package:flutter/material.dart';

class SnackbarHelper {
  static String parseError(String error) {
    if (error.contains('invalid-credential') ||
        error.contains('wrong-password')) {
      return 'Invalid email or password';
    } else if (error.contains('user-not-found')) {
      return 'No account found with this email';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Try again later';
    } else if (error.contains('network-request-failed')) {
      return 'No internet connection';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('channel-error')) {
      return 'Please fill in all fields';
    } else if (error.contains('Removed from cart')) {
      return 'Removed from cart';
    } else if (error.contains('Removed from wishlist')) {
      return 'Removed from wishlist';
    }
    return 'Something went wrong. Please try again';
  }

  static void showError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(parseError(error))),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
