import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:thrift_corner/core/utils/snackbar_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset('assets/logo/logo.png', width: 100),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Forgot Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your email to reset your password',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(164, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: emailController.text.trim(),
                      );
                      if (context.mounted) {
                        SnackbarHelper.showSuccess(
                          context,
                          'Password reset email sent!',
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        SnackbarHelper.showError(context, e.code);
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color.fromARGB(200, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
