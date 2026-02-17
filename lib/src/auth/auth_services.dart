import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class OAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // static const String _serverClientId = "";

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isInitialized = false;

  Future<void> initialized() async {
    try {
      if (!_isInitialized) {
        await _googleSignIn.initialize(serverClientId: dotenv.env['SERVER_CLIENT_ID']);
      }
      _isInitialized = !_isInitialized;
    } catch (e) {
      throw e.toString();
    }
  }

  Future oAuthSignIn() async {
    try {
      initialized();
      final GoogleSignInAccount signIn = await _googleSignIn.authenticate();
      final idToken = signIn.authentication.idToken;
      final authorizationClient = signIn.authorizationClient;
      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(["email", "profile"]);
      final accessToken = authorization?.accessToken;
      if (accessToken == null) {
        final authorization2 = await authorizationClient.authorizationForScopes(
          ["email", "profile"],
        );
        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "erorr", message: "erorr");
        }
        authorization = authorization2;
      }
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        final userData = {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'userinterest': [],
          'createdAt': FieldValue.serverTimestamp(),
          'profileCompleted': false,
          'role': 'user',
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
      }
      // return false;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
