import 'package:firebase_auth/firebase_auth.dart';

class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String error;
  AuthError({required this.error});
}

class AuthAuthenticated extends AuthState {
  final UserCredential userCredential;

  AuthAuthenticated({required this.userCredential});
}

class AuthPasswordResetSent extends AuthState {}

class AuthLoggedOut extends AuthState {}

class OnboardingCompleted extends AuthState {}

class AuthAuthenticatedNeedsOnboarding extends AuthState {
  final UserCredential userCredential;
  AuthAuthenticatedNeedsOnboarding({required this.userCredential});
}
