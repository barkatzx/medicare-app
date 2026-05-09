import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/verify_auth_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyAuthUseCase verifyAuthUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyAuthUseCase,
  });

  UserEntity? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _pendingApprovalMessage;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String? get pendingApprovalMessage => _pendingApprovalMessage;
  bool get isLoggedIn => _currentUser != null && _currentUser!.isApproved;
  bool get isCustomer => _currentUser?.isCustomer ?? false;
  bool get isPendingApproval =>
      _currentUser != null && !_currentUser!.isApproved;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      final user = await verifyAuthUseCase.execute();
      _currentUser = user;
      _pendingApprovalMessage = null;
    } catch (e) {
      _currentUser = null;
      if (e.toString().contains('pending approval')) {
        _pendingApprovalMessage = e.toString();
      }
      debugPrint('Auth initialization failed: $e');
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    _pendingApprovalMessage = null;

    try {
      final user = await loginUseCase.execute(
        phoneNumber: phoneNumber,
        password: password,
      );

      _currentUser = user;
      _isInitialized = true;
      _setLoading(false);
      return true;
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('pending approval')) {
        _pendingApprovalMessage = errorString;
      } else {
        _errorMessage = errorString;
      }
      _currentUser = null;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    _pendingApprovalMessage = null;

    try {
      final user = await registerUseCase.execute(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      _currentUser = user;
      _isInitialized = true;
      _setLoading(false);
      return true;
    } catch (e) {
      final errorString = e.toString();
      if (errorString.contains('pending approval')) {
        _pendingApprovalMessage = errorString;
      } else {
        _errorMessage = errorString;
      }
      _currentUser = null;
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await loginUseCase.repository.logout();
    _currentUser = null;
    // We intentionally keep _isInitialized = true, because the app has already done
    // its initial setup. It just means the current state is "logged out".
    _pendingApprovalMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    _pendingApprovalMessage = null;
    notifyListeners();
  }
}
