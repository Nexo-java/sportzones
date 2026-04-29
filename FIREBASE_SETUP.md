# Firebase Authentication Integration - Panduan Lengkap

## 🔍 Masalah Yang Terjadi

**Kenapa Firebase login tidak bekerja?**

Sebelumnya, LoginScreen menggunakan **mock data** (data hardcoded) bukan Firebase:
```dart
// ❌ SEBELUMNYA - Hanya pakai mock data
UserRepository.instance.initializeSampleData(); // Load admin/user123, hendrik/user123
final loginSuccess = UserRepository.instance.login(username, password);
```

Padahal Kamu sudah setup Firebase dengan credentials di `firebase_options.dart`. Sistem tidak terhubung sama sekali dengan Firebase!

---

## ✅ Solusi Yang Sudah Diimplementasi

### 1. **Buat FirebaseAuthService** (`lib/services/firebase_auth_service.dart`)
Service baru yang handle Firebase Authentication:
```dart
// ✅ Login dengan Firebase
Future<bool> loginWithEmail({
  required String email,
  required String password,
}) async {
  final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password.trim(),
  );
  // Sync user data ke UserRepository
  await _syncUserFromFirebase(userCredential.user!.uid);
  return true;
}

// ✅ Register dengan Firebase
Future<bool> registerWithEmail({
  required String email,
  required String password,
  required String username,
}) async {
  // Create Firebase Auth user
  // Save user data ke Firestore
  // Sync ke UserRepository
}

// ✅ Logout dari Firebase
Future<void> logout() async {
  await _firebaseAuth.signOut();
  UserRepository.instance.logout();
}
```

### 2. **Update LoginScreen** (`lib/features/authentication/screens/login_screen.dart`)
Sekarang pakai `FirebaseAuthService` bukan mock data:
```dart
// ✅ SEKARANG - Login dengan Firebase
final loginSuccess = await FirebaseAuthService.instance.loginWithEmail(
  email: email,
  password: password,
);

// ✅ Register dengan Firebase
await FirebaseAuthService.instance.registerWithEmail(
  email: email,
  password: password,
  username: username,
);
```

### 3. **Add Firebase Initialization** (`lib/main.dart`)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 4. **Update UserRepository** 
Tambah `setCurrentUser()` method untuk support Firebase user sync:
```dart
/// Set current user (used by Firebase authentication)
void setCurrentUser(UserModel user) {
  _currentUser = user;
  if (!_users.containsKey(user.idUser)) {
    _users[user.idUser] = user;
  }
  _notifyListeners();
}
```

---

## 📋 Data Flow Sekarang

```
User Login dengan Email/Password
    ↓
FirebaseAuthService.loginWithEmail()
    ↓
Firebase Authentication ✅
    ↓
_syncUserFromFirebase(uid)
    ↓
Fetch dari Firestore collection 'users'
    ↓
UserRepository.setCurrentUser()
    ↓
UserService.setRole()
    ↓
Navigate ke HomeScreen
```

---

## 🚀 Cara Pakai/Testing

### **Test 1: Login dengan Firebase**
1. Kamu harus sudah punya user di Firebase Authentication
2. User data juga harus ada di Firestore collection `users`

Firestore document structure:
```json
{
  "id_user": "uid_dari_firebase",
  "username": "nama_pengguna",
  "email": "email@example.com",
  "role": "admin",  // atau "user"
  "saved_news": ["news_id_1", "news_id_2"],
  "img_url": null,
  "created_at": "2026-04-28T10:00:00Z"
}
```

### **Test 2: Register User Baru**
1. Buka app → Register tab
2. Isi username, email, password
3. Click Register
4. Sistem akan:
   - Create Firebase Auth user
   - Create user document di Firestore
   - Sync ke UserRepository
   - Auto switch ke Login tab

### **Test 3: Mock Data (Optional - Fallback)**
Jika Firebase tidak available, bisa fallback ke mock data:
```dart
// Di LoginScreen
if (loginSuccess) {
  // Firebase berhasil
} else {
  // Optional: coba mock data
  UserRepository.instance.initializeSampleData();
  final mockSuccess = UserRepository.instance.login(username, password);
}
```

---

## 📱 Setup Firebase Console

1. **Buka Firebase Console** → sportzones-1267b project
2. **Enable Email/Password Auth:**
   - Authentication → Sign-in method
   - Enable "Email/Password"
   
3. **Create Firestore Database:**
   - Build → Firestore Database
   - Create collection: `users`
   - Add sample user documents

4. **Create Sample User di Firebase Auth:**
   - Authentication → Users
   - Tambah user (email + password)

5. **Add User Document di Firestore:**
   ```
   Collection: users
   Document ID: (gunakan UID dari Firebase Auth)
   Data: 
   {
     "id_user": "uid_dari_firebase",
     "username": "testuser",
     "email": "test@example.com",
     "role": "user",
     "saved_news": [],
     "img_url": null,
     "created_at": "2026-04-28T..."
   }
   ```

---

## ⚙️ Features Yang Sudah Ready

✅ **Login dengan Firebase** - Email & password authentication
✅ **Register User Baru** - Create akun baru di Firebase
✅ **User Data Sync** - Auto fetch dari Firestore ke local
✅ **Role Management** - Admin/User role dari Firestore
✅ **Logout** - Secure logout dari Firebase
✅ **Saved News Sync** - bookmarks disimpan di Firestore array
✅ **Profile Update** - Ubah data user di Firestore

---

## 🔧 Features Yang Masih Perlu Diwiring

⚠️ **SavedNews CRUD** - addSavedNews(), removeSavedNews() 
   → Harus wiring ke Firestore array updates

⚠️ **News Edit/Delete** - NewsRepository ubahData(), hapusData()
   → Harus simpan ke Firestore `news` collection (belum dibuat)

⚠️ **Like System** - NewsRepository addLike(), removeLike()
   → Harus track likes di Firestore

⚠️ **Search** - NewsRepository searchByTitle()
   → Belum wiring ke Firestore query

---

## 📝 Compilation Status

✅ `dart analyze` → **No issues found!**

All Firebase integration code sudah clean dan ready untuk testing.

---

## 🎯 Next Steps Untuk Testing

1. **Setup Firebase Console** sesuai panduan di atas
2. **Create test user** di Firebase Authentication
3. **Add user document** di Firestore `users` collection
4. **Run app** dan test login/register flow
5. **Check logs** untuk error messages

Jika ada error saat login, check:
- Firebase credentials di `firebase_options.dart` sudah benar?
- User ada di Firebase Authentication?
- User document ada di Firestore `users` collection?
- Email format benar?

**Good luck! 🚀**
