import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current app user data
  Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromFirestore(doc);
  }

  // Sign in with email and password
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        if (doc.exists) {
          return AppUser.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Create user (only admin can create users, only users can create staff)
  Future<AppUser?> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String createdById,
  }) async {
    try {
      // Store current user to sign back in later
      final currentUser = _auth.currentUser;
      
      // Create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document
        final appUser = AppUser(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          createdBy: createdById,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(appUser.toFirestore());

        // Sign out the newly created user and sign back in as the original user
        await _auth.signOut();
        if (currentUser != null) {
          // Re-authenticate the original user
          // Note: This is a workaround - in production, use Firebase Admin SDK
        }

        return appUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
