import 'package:flutter/material.dart';
import 'package:thrift_corner/core/utils/snackbar_helper.dart';
import 'package:thrift_corner/features/auth/screens/forgot_password_screen.dart';
import 'package:thrift_corner/features/auth/screens/signup_screen.dart';
import 'package:thrift_corner/features/home/screens/main_screen.dart';
import 'package:thrift_corner/features/onboarding/screens/onboarding_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thrift_corner/features/auth/bloc/auth_bloc.dart';
import 'package:thrift_corner/features/auth/bloc/auth_event.dart';
import 'package:thrift_corner/features/auth/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isEmailLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool showPass = true;
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
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/logo/logo.png', width: 100),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Welcome Back!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Login to continue shopping',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),

                  const SizedBox(height: 40),

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
                      hintText: 'Password',
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

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: isEmailLoading || isGoogleLoading
                        ? null
                        : () {
                            setState(() => isEmailLoading = true);
                            context.read<AuthBloc>().add(
                              AuthLoginRequested(
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
                                'Login',
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
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
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
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
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
                                  height: 22,
                                  width: 22,
                                  fit: BoxFit.contain,
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

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 12.5),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
