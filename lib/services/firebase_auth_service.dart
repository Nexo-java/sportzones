import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/authentication/models/user_model.dart';
import 'user_repository.dart';

/// Service untuk handle Firebase Authentication dan user data sync
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  
  factory FirebaseAuthService() {
    return _instance;
  }
  
  FirebaseAuthService._internal();
  
  static FirebaseAuthService get instance => _instance;
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar di Firebase Authentication.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Coba lagi.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }
  
  /// Get current logged in user from Firebase
  User? get currentFirebaseUser => _firebaseAuth.currentUser;
  
  /// Login dengan email dan password dari Firebase
  /// Returns true jika login berhasil
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (userCredential.user != null) {
        // Fetch user data dari Firestore dan set di UserRepository
        await _syncUserFromFirebase(userCredential.user!.uid);
        return true;
      }
      return false;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }
  
  /// Register user baru dengan email dan password
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    UserCredential? createdCredential;
    try {
      // Create Firebase Auth user
      createdCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (createdCredential.user != null) {
        final uid = createdCredential.user!.uid;
        
        // Save user document ke Firestore
        await _firebaseFirestore.collection('users').doc(uid).set({
          'id_user': uid,
          'username': username.trim(),
          'email': email.trim(),
          'role': 'user',
          'saved_news': [],
          'img_url': {
            'url': '',
            'source': 'default',
          },
          'created_at': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
        
        // Sync ke UserRepository
        await _syncUserFromFirebase(uid);
        return null;
      }
      return 'Gagal membuat akun. Silakan coba lagi.';
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e);
    } on FirebaseException catch (e) {
      // Rollback akun Auth kalau Firestore gagal simpan user profile
      if (createdCredential?.user != null) {
        await createdCredential!.user!.delete();
        await _firebaseAuth.signOut();
      }
      return e.message ?? 'Gagal menyimpan data user ke Firestore.';
    } catch (_) {
      if (createdCredential?.user != null) {
        await createdCredential!.user!.delete();
        await _firebaseAuth.signOut();
      }
      return 'Terjadi kesalahan saat register. Coba lagi.';
    }
  }
  
  /// Sync user data dari Firebase ke UserRepository
  Future<void> _syncUserFromFirebase(String uid) async {
    try {
      final doc = await _firebaseFirestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        final dynamic imgRaw = data['img_url'];
        Map<String, dynamic>? parsedImgUrl;
        if (imgRaw is Map<String, dynamic>) {
          parsedImgUrl = Map<String, dynamic>.from(imgRaw);
        } else if (imgRaw is String) {
          parsedImgUrl = {
            'url': imgRaw,
            'source': 'legacy',
          };
        }

        final userModel = UserModel(
          idUser: data['id_user'] ?? uid,
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          password: data['password'] ?? '',
          role: data['role'] ?? 'user',
          savedNews: List<String>.from(data['saved_news'] ?? []),
          imgUrl: parsedImgUrl,
        );
        
        // Set sebagai current user di UserRepository
        UserRepository.instance.setCurrentUser(userModel);
      }
    } catch (e) {
      // Silent error handling for sync
    }
  }
  
  /// Logout dari Firebase
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      UserRepository.instance.logout();
    } catch (e) {
      // Silent error handling
    }
  }
  
  /// Update user profile di Firebase dan UserRepository
  Future<bool> updateUserProfile({
    required String userId,
    required String username,
    required String email,
    required String? imgUrl,
  }) async {
    try {
      // Update di Firestore
      await _firebaseFirestore.collection('users').doc(userId).update({
        'username': username,
        'email': email,
        'img_url': {
          'url': imgUrl ?? '',
          'source': 'profile_update',
        },
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      // Update di UserRepository
      await _syncUserFromFirebase(userId);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Add saved news ke Firebase dan UserRepository
  Future<bool> addSavedNews({
    required String userId,
    required String newsId,
  }) async {
    try {
      final userRef = _firebaseFirestore.collection('users').doc(userId);
      
      // Add ke array di Firestore
      await userRef.update({
        'saved_news': FieldValue.arrayUnion([newsId]),
      });
      
      // Sync ke UserRepository
      await _syncUserFromFirebase(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove saved news dari Firebase dan UserRepository
  Future<bool> removeSavedNews({
    required String userId,
    required String newsId,
  }) async {
    try {
      final userRef = _firebaseFirestore.collection('users').doc(userId);
      
      // Remove dari array di Firestore
      await userRef.update({
        'saved_news': FieldValue.arrayRemove([newsId]),
      });
      
      // Sync ke UserRepository
      await _syncUserFromFirebase(userId);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if user exists di Firebase by email
  Future<bool> userExists(String email) async {
    try {
      // Try to sign in anonymously first to check user
      final doc = await _firebaseFirestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      return doc.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
