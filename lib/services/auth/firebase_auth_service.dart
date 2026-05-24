import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/authentication/models/user_model.dart';
import '../user/user_repository.dart';

/// Service untuk mengurus autentikasi Firebase dan sinkronisasi data user.
///
/// Tugas utamanya:
/// - login dan register user ke Firebase Auth
/// - menyimpan profil user ke Firestore
/// - membaca data user dari Firestore lalu memasukkannya ke `UserRepository`
/// - update profil, bookmark berita, dan logout
class FirebaseAuthService {
  /// Singleton instance agar service ini dipakai dari satu titik saja.
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  /// Factory constructor untuk selalu mengembalikan instance yang sama.
  factory FirebaseAuthService() {
    return _instance;
  }

  /// Konstruktor privat supaya instance hanya bisa dibuat dari dalam class.
  FirebaseAuthService._internal();

  /// Akses global yang paling sering dipakai di aplikasi.
  static FirebaseAuthService get instance => _instance;

  /// Referensi ke Firebase Authentication untuk proses login/register/logout.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  /// Referensi ke Firestore untuk menyimpan dan membaca data user.
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// Mengubah kode error Firebase menjadi pesan yang lebih mudah dipahami user.
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

  /// Mengambil user yang sedang login langsung dari Firebase Auth.
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Login memakai email dan password dari Firebase Auth.
  ///
  /// Alur:
  /// 1. kirim kredensial ke Firebase Auth
  /// 2. kalau berhasil, ambil data profil user dari Firestore
  /// 3. sinkronkan hasilnya ke `UserRepository`
  /// 4. kembalikan true jika login sukses
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      /// Meminta Firebase Auth memverifikasi email dan password user.
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        /// Setelah login berhasil, ambil profil user dari Firestore.
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

  /// Register user baru ke Firebase Auth lalu simpan profilnya ke Firestore.
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    /// Menyimpan credential sementara agar bisa dihapus jika Firestore gagal.
    UserCredential? createdCredential;
    try {
      /// Membuat akun autentikasi baru di Firebase Auth.
      createdCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (createdCredential.user != null) {
        /// UID dari Firebase dipakai sebagai ID user di Firestore.
        final uid = createdCredential.user!.uid;

        /// Simpan data profil user ke koleksi `users` di Firestore.
        await _firebaseFirestore.collection('users').doc(uid).set({
          'id_user': uid,
          'username': username.trim(),
          'email': email.trim(),
          'role': 'user',
          'saved_news': [],
          'img_url': {'url': '', 'source': 'default'},
          'created_at': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        /// Setelah tersimpan, sinkronkan data Firestore ke repository lokal.
        await _syncUserFromFirebase(uid);
        return null;
      }
      return 'Gagal membuat akun. Silakan coba lagi.';
    } on FirebaseAuthException catch (e) {
      /// Jika masalah dari Auth, ubah jadi pesan yang lebih manusiawi.
      return _friendlyAuthError(e);
    } on FirebaseException catch (e) {
      /// Jika Firestore gagal, hapus akun Auth yang sudah terlanjur dibuat.
      if (createdCredential?.user != null) {
        await createdCredential!.user!.delete();
        await _firebaseAuth.signOut();
      }
      return e.message ?? 'Gagal menyimpan data user ke Firestore.';
    } catch (_) {
      /// Fallback terakhir kalau error lain terjadi di luar dugaan.
      if (createdCredential?.user != null) {
        await createdCredential!.user!.delete();
        await _firebaseAuth.signOut();
      }
      return 'Terjadi kesalahan saat register. Coba lagi.';
    }
  }

  /// Mengambil data user dari Firestore lalu memasukkannya ke `UserRepository`.
  Future<void> _syncUserFromFirebase(String uid) async {
    try {
      /// Baca dokumen profil user berdasarkan UID.
      final doc = await _firebaseFirestore.collection('users').doc(uid).get();

      if (doc.exists) {
        /// Ambil isi dokumen Firestore.
        final data = doc.data()!;
        /// Bisa berupa Map lama atau String legacy, jadi perlu dinormalisasi.
        final dynamic imgRaw = data['img_url'];
        Map<String, dynamic>? parsedImgUrl;
        if (imgRaw is Map<String, dynamic>) {
          /// Jika data gambar sudah Map, salin ke format aman.
          parsedImgUrl = Map<String, dynamic>.from(imgRaw);
        } else if (imgRaw is String) {
          /// Jika masih bentuk string lama, ubah ke struktur Map baru.
          parsedImgUrl = {'url': imgRaw, 'source': 'legacy'};
        }

        /// Bentuk model user dari data mentah Firestore.
        final userModel = UserModel(
          idUser: data['id_user'] ?? uid,
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          password: data['password'] ?? '',
          role: data['role'] ?? 'user',
          savedNews: List<String>.from(data['saved_news'] ?? []),
          imgUrl: parsedImgUrl,
        );

        /// Simpan user aktif ke repository agar UI bisa mengaksesnya.
        UserRepository.instance.setCurrentUser(userModel);
      }
    } catch (e) {
      /// Sinkronisasi dibuat silent supaya UI tidak crash jika fetch gagal.
    }
  }

  /// Logout dari Firebase Auth dan bersihkan state user lokal.
  Future<void> logout() async {
    try {
      /// Putus sesi login dari Firebase.
      await _firebaseAuth.signOut();
      /// Kosongkan user aktif di repository.
      UserRepository.instance.logout();
    } catch (e) {
      /// Error logout tidak ditampilkan supaya flow keluar tetap aman.
    }
  }

  /// Update profil user di Firestore lalu sinkronkan lagi ke repository lokal.
  Future<bool> updateUserProfile({
    required String userId,
    required String username,
    required String email,
    required String? imgUrl,
  }) async {
    try {
      /// Update field profil yang tampil di aplikasi.
      await _firebaseFirestore.collection('users').doc(userId).update({
        'username': username,
        'email': email,
        'img_url': {'url': imgUrl ?? '', 'source': 'profile_update'},
        'updated_at': DateTime.now().toIso8601String(),
      });

      /// Ambil ulang data terbaru agar repository ikut terbarui.
      await _syncUserFromFirebase(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Menambahkan ID berita yang disimpan ke array `saved_news` di Firestore.
  Future<bool> addSavedNews({
    required String userId,
    required String newsId,
  }) async {
    try {
      /// Reference ke dokumen user yang sedang di-update.
      final userRef = _firebaseFirestore.collection('users').doc(userId);

      /// Tambahkan ID berita tanpa menghapus isi array yang lama.
      await userRef.update({
        'saved_news': FieldValue.arrayUnion([newsId]),
      });

      /// Update repository lokal agar UI langsung membaca data terbaru.
      await _syncUserFromFirebase(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Menghapus ID berita dari array `saved_news` di Firestore.
  Future<bool> removeSavedNews({
    required String userId,
    required String newsId,
  }) async {
    try {
      /// Reference ke user yang bookmark-nya mau dikurangi.
      final userRef = _firebaseFirestore.collection('users').doc(userId);

      /// Hapus ID berita dari list bookmark user.
      await userRef.update({
        'saved_news': FieldValue.arrayRemove([newsId]),
      });

      /// Sync ulang supaya daftar bookmark di UI ikut berubah.
      await _syncUserFromFirebase(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mengecek apakah email user sudah terdaftar di koleksi `users`.
  Future<bool> userExists(String email) async {
    try {
      /// Cari dokumen user dengan email yang sama, lalu batasi 1 hasil.
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
