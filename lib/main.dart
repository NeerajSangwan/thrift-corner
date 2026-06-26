import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thrift_corner/features/auth/bloc/auth_bloc.dart';
import 'package:thrift_corner/features/auth/screens/splash_screen.dart';
import 'package:thrift_corner/features/auth/services/auth_service.dart';
import 'package:thrift_corner/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(AuthService()),
      child: MaterialApp(
        title: 'Thrift Corner',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
