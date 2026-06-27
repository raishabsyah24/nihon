import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../firebase_options.dart';
import '../models/app_models.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required this.apiBaseUrl,
    this.googleServerClientId = '',
  });

  final String apiBaseUrl;
  final String googleServerClientId;

  bool _firebaseReady = false;
  bool _isBusy = false;
  bool _googleReady = false;
  String? _errorMessage;
  AppUser? _profile;

  bool get firebaseReady => _firebaseReady;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  AppUser? get profile => _profile;
  bool get isSignedIn => _profile != null;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseReady = true;

      firebase.FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user == null) {
          _profile = null;
          notifyListeners();
          return;
        }
        await refreshProfile();
      });

      if (firebase.FirebaseAuth.instance.currentUser != null) {
        await refreshProfile();
      }
    } catch (error) {
      _firebaseReady = false;
      _errorMessage = 'Firebase belum dikonfigurasi: $error';
    }
  }

  Future<String?> getIdToken() async {
    if (!_firebaseReady) {
      return null;
    }
    return firebase.FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<void> signInWithGoogle() async {
    await _guarded(() async {
      _requireFirebase();
      await _initializeGoogle();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw StateError(
          'Google Sign-In interaktif tidak didukung di platform ini.',
        );
      }

      final googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw StateError('Google tidak mengembalikan ID token.');
      }

      final credential = firebase.GoogleAuthProvider.credential(
        idToken: idToken,
      );
      await firebase.FirebaseAuth.instance.signInWithCredential(credential);
      await refreshProfile();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _guarded(() async {
      _requireFirebase();
      await firebase.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await refreshProfile();
    });
  }

  Future<void> registerWithEmail(String email, String password) async {
    await _guarded(() async {
      _requireFirebase();
      await firebase.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await refreshProfile();
    });
  }

  Future<void> sendPasswordResetEmail() async {
    await _guarded(() async {
      _requireFirebase();
      final email =
          firebase.FirebaseAuth.instance.currentUser?.email ?? _profile?.email;
      if (email == null || email.trim().isEmpty) {
        throw StateError('Email akun belum tersedia untuk reset password.');
      }
      await firebase.FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );
    });
  }

  Future<void> refreshProfile() async {
    if (!_firebaseReady) {
      return;
    }

    final user = firebase.FirebaseAuth.instance.currentUser;
    if (user == null) {
      _profile = null;
      notifyListeners();
      return;
    }

    try {
      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _profile = AppUser.fromJson(jsonDecode(response.body) as JsonMap);
      } else {
        _profile = _firebaseUserFallback(user);
      }
    } catch (_) {
      _profile = _firebaseUserFallback(user);
    }

    notifyListeners();
  }

  Future<void> signOut() async {
    await _guarded(() async {
      if (_firebaseReady) {
        await firebase.FirebaseAuth.instance.signOut();
      }
      if (_googleReady) {
        await GoogleSignIn.instance.signOut();
      }
      _profile = null;
    });
  }

  void useDemoUser({required bool admin}) {
    _profile = AppUser(
      id: admin ? 'demo-admin' : 'demo-user',
      role: admin ? 'ADMIN' : 'USER',
      email: admin ? 'admin@nihoneikitai.local' : 'user@nihoneikitai.local',
      displayName: admin ? 'Demo Admin' : 'Demo User',
      phoneNumber: null,
    );
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _initializeGoogle() async {
    if (_googleReady) {
      return;
    }
    final serverClientId = googleServerClientId.trim();
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        serverClientId.isEmpty) {
      throw StateError(
        'GOOGLE_SERVER_CLIENT_ID belum diisi. Gunakan Web client ID Firebase saat menjalankan atau build APK.',
      );
    }
    await GoogleSignIn.instance.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    _googleReady = true;
  }

  Future<void> _guarded(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _requireFirebase() {
    if (!_firebaseReady) {
      throw StateError(
        'Firebase belum dikonfigurasi. Tambahkan konfigurasi Firebase untuk mobile.',
      );
    }
  }

  AppUser _firebaseUserFallback(firebase.User user) {
    return AppUser(
      id: user.uid,
      role: 'USER',
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
