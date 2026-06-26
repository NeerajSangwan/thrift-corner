import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thrift_corner/features/auth/bloc/auth_event.dart';
import 'package:thrift_corner/features/auth/bloc/auth_state.dart';
import 'package:thrift_corner/features/auth/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignupRequested);
    on<CompleteOnboardingRequested>(_onCompleteOnboardingRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await authService.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(userCredential: userCredential));
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }

  Future<void> _onSignupRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authService.signup(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      final userCredential = await authService.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticatedNeedsOnboarding(userCredential: userCredential));
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }

  Future<void> _onCompleteOnboardingRequested(
    CompleteOnboardingRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authService.completeOnboarding(
        phone: event.phone,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
      );

      emit(OnboardingCompleted());
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final userCredential = await authService.signInWithGoogle();

      if (userCredential == null) {
        emit(AuthInitial());
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final onboardingCompleted = doc.data()?['onboardingCompleted'] == true;

      if (onboardingCompleted) {
        emit(AuthAuthenticated(userCredential: userCredential));
      } else {
        emit(AuthAuthenticatedNeedsOnboarding(userCredential: userCredential));
      }
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }
}
