# 📱 YACK — Your Agreement Contract Keeper
**YACK (Your Agreement Contract Keeper)** is a Flutter mobile app that allows users to **create, sign, and verify digital contracts** securely. It ensures authenticity and integrity using **hashing**, with future plans for **blockchain verification**, **GPS tracking**, and **Face ID authentication**.

## 🚀 Features
- ✍️ Create, sign, and manage contracts
- 🔐 Secure data using hashing
- ☁️ Firebase integration (Auth, Firestore, Storage)
- 🧾 View and verify signed agreements
- 📍 Future: GPS and Face ID verification
- ⛓️ Future: Blockchain-backed proof of authenticity

## 🏗️ Project Structure
lib/  
├── main.dart  
├── config/  
│   ├── app_theme.dart  
│   ├── constants.dart  
│   └── routes.dart  
├── models/  
│   ├── user_model.dart  
│   └── contract_model.dart  
├── services/  
│   ├── auth_service.dart  
│   ├── contract_service.dart  
│   ├── hash_service.dart  
│   └── storage_service.dart  
├── providers/  
│   ├── auth_provider.dart  
│   └── contract_provider.dart  
├── screens/  
│   ├── login_screen.dart  
│   ├── home_screen.dart  
│   ├── create_contract_screen.dart  
│   └── verify_contract_screen.dart  
├── widgets/  
│   ├── custom_button.dart  
│   ├── input_field.dart  
│   └── contract_card.dart  
└── utils/  
├── validators.dart  
└── snackbar_helper.dart

## ⚙️ Firebase Setup for YACK
### 1. Create a Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com)
- Click **Add Project** → name it `yack-app`
- Enable **Google Analytics** (optional)

### 2. Register Your Flutter App
**For Android:**
- Add package name (e.g., `com.example.yack`)
- Download `google-services.json`
- Place it in `android/app/google-services.json`

**For iOS:**
- Download `GoogleService-Info.plist`
- Place it in `ios/Runner/GoogleService-Info.plist`

### 3. Add Firebase Dependencies
Run these commands:
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_storage

arduino
Copy code
Then run:
flutter pub get

perl
Copy code

### 4. Initialize Firebase in Flutter
In your `main.dart`:
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const YackApp());
}

class YackApp extends StatelessWidget {
const YackApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'YACK',
theme: ThemeData(primarySwatch: Colors.blue),
home: const HomeScreen(),
);
}
}

shell
Copy code

### 5. Verify Connection
Run the app:
flutter run

nginx
Copy code
If no errors appear, Firebase is connected successfully ✅

## 🧠 Example: Authentication Service
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
final _auth = FirebaseAuth.instance;

Future<User?> signIn(String email, String password) async {
final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
return result.user;
}

Future<User?> signUp(String email, String password) async {
final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
return result.user;
}

Future<void> signOut() async {
await _auth.signOut();
}
}

shell
Copy code

## 🧾 Example: Save a Contract to Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractService {
final _firestore = FirebaseFirestore.instance;

Future<void> saveContract(String title, String hash, String userId) async {
await _firestore.collection('contracts').add({
'title': title,
'hash': hash,
'ownerId': userId,
'createdAt': FieldValue.serverTimestamp(),
});
}

Stream<QuerySnapshot> getUserContracts(String userId) {
return _firestore
.collection('contracts')
.where('ownerId', isEqualTo: userId)
.snapshots();
}
}

markdown
Copy code

## 🧰 Tech Stack
| Category | Technology                        |
|-----------|-----------------------------------|
| Frontend | Flutter                           |
| Backend | Firebase (Auth, Firestore, Storage) |
| Language | Dart                              |
| Security | Hashing                           |
| Platform | Android                           |

## 📦 Future Enhancements
- GPS location verification
- Face ID / Fingerprint authentication
- Blockchain contract hashing
- In-app signature pad

## 📜 License
This project is licensed under the **MIT License**.

## ❤️ Author
**YACK Team**  
_Your Agreement Contract Keeper — simple, secure, and smart digital contracts._