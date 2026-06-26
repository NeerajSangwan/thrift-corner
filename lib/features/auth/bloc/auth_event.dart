class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  AuthSignUpRequested({
    required this.email,
    required this.name,
    required this.password,
  });
}

class CompleteOnboardingRequested extends AuthEvent {
  final String phone;
  final String gender;
  final DateTime dateOfBirth;

  CompleteOnboardingRequested({
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
  });
}

class GoogleSignInRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  AuthForgotPasswordRequested({required this.email});
}

class LogOutRequested extends AuthEvent {}
