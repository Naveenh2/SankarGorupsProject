import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService) {
    _authSubscription = _authService.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _authSubscription;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.login(email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? 'Login failed';
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signUp(email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? 'Signup failed';
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.logout();
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? 'Logout failed';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
