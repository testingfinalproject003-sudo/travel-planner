import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserModel?> get currentUser async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUserData(user.uid);
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('User data retrieve karne mein error aya: $e');
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Authentication failed');
    } catch (e) {
      throw Exception('Login execute karne mein error aya: $e');
    }
  }

  Future<UserCredential> signup(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        final newUser = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          photoURL: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=1A3FBF&color=ffffff',
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Signup failed');
    } catch (e) {
      throw Exception('Account creation processing failure: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}