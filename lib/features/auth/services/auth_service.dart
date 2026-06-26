import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await userCredential.user!.updateDisplayName(name);

    return userCredential;
  }

  Future<void> completeOnboarding({
    required String phone,
    required String gender,
    required DateTime dateOfBirth,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'phone': phone,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'onboardingCompleted': true,
    }, SetOptions(merge: true));
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        return null;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final uid = userCredential.user!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'phone': '',
          'gender': '',
          'dateOfBirth': null,
          'onboardingCompleted': false,
        });
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }
}
