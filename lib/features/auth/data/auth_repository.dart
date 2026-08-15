import 'package:chronos/features/auth/domain/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChange => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    final appUser = AppUser(
      uid: user.uid,
      email: email.trim(),
      name: name,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
    return appUser;
  }
  Future<AppUser> signIn({
  required String email,
  required String password,
}) async {
  final credential = await _auth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password,
  );

  final doc = await _firestore
      .collection('users')
      .doc(credential.user!.uid)
      .get();

  if (!doc.exists || doc.data() == null) {
    throw Exception('User profile not found.');
  }

  return AppUser.fromMap(doc.data()!);
}

  Future<void> signOut() async{
    await _auth.signOut();
  }

  Future<AppUser?> getUserData(String uid)async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  Future<void> sendPasswordResetEmail(String email) async{
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
  
}
