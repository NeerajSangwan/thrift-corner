import 'package:flutter/material.dart';
import 'package:thrift_corner/features/auth/screens/login_screen.dart';
import 'package:thrift_corner/features/home/screens/main_screen.dart';
import 'package:thrift_corner/features/onboarding/screens/onboarding_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thrift_corner/features/auth/bloc/auth_bloc.dart';
import 'package:thrift_corner/features/auth/bloc/auth_event.dart';
import 'package:thrift_corner/features/auth/bloc/auth_state.dart';

import 'package:thrift_corner/core/utils/snackbar_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _validate() {
    if (nameController.text.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!emailController.text.trim().endsWith('@gmail.com')) {
      return 'Enter a valid Gmail address';
    }
    if (passwordController.text.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool isEmailLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool showPass = true;
  bool showConfirmPass = true;

  void toggleshowConfirmPass() {
    setState(() {
      showConfirmPass = !showConfirmPass;
    });
  }

  void toggleShowPassword() {
    setState(() {
      showPass = !showPass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }

        if (state is AuthAuthenticatedNeedsOnboarding) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
        if (state is AuthInitial) {
          setState(() {
            isGoogleLoading = false;
            isEmailLoading = false;
          });
        }

        if (state is AuthError) {
          setState(() {
            isEmailLoading = false;
            isGoogleLoading = false;
          });
          SnackbarHelper.showError(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/logo/logo.png', width: 100),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Create New Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      prefixIcon: const Icon(Icons.person),

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

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    obscureText: showPass,
                    decoration: InputDecoration(
                      hintText: 'Create Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: GestureDetector(
                        onTap: toggleShowPassword,
                        child: Icon(
                          showPass ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),

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

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: showConfirmPass,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: GestureDetector(
                        onTap: toggleshowConfirmPass,
                        child: Icon(
                          showConfirmPass
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),

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

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () {
                      final error = _validate();
                      if (error != null) {
                        SnackbarHelper.showError(context, error);
                        return;
                      }
                      setState(() => isEmailLoading = true);
                      context.read<AuthBloc>().add(
                        AuthSignUpRequested(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isEmailLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign Up',
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

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: isEmailLoading || isGoogleLoading
                        ? null
                        : () {
                            setState(() => isGoogleLoading = true);
                            context.read<AuthBloc>().add(
                              GoogleSignInRequested(),
                            );
                          },
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isGoogleLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Image.asset(
                                  'assets/logo/google-logo.png',
                                  height: 24,
                                  width: 24,
                                ),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 12.5),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
