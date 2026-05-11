import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/verify_auth_usecase.dart';
import '../../domain/usecases/auth/get_profile_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/change_password_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyAuthUseCase verifyAuthUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyAuthUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
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
      // 1. Try to load cached user first for immediate UI responsiveness
      final cachedUser = await loginUseCase.repository.getUser();
      if (cachedUser != null) {
        _currentUser = cachedUser;
        _isInitialized = true;
        _setLoading(false);
        // Notify UI that we have a user (Home screen will show)
        notifyListeners(); 
      }

      // 2. Verify/Refresh authentication with the backend in the background or semi-background
      final verifiedUser = await verifyAuthUseCase.execute();
      _currentUser = verifiedUser;
      _pendingApprovalMessage = null;
    } catch (e) {
      // If we don't have a cached user AND verification failed, then we are logged out
      if (_currentUser == null) {
        _currentUser = null;
        if (e.toString().contains('pending approval')) {
          _pendingApprovalMessage = e.toString();
        }
      } else {
        // If we HAD a cached user but verification failed:
        // If it's a "Session expired" error (cleared in repository), the repository 
        // already called logout/clear. We just need to sync the provider state.
        final stillHasUser = await loginUseCase.repository.getUser();
        if (stillHasUser == null) {
          _currentUser = null;
          _errorMessage = e.toString();
        }
      }
      debugPrint('Auth initialization detail: $e');
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

  Future<void> getProfile() async {
    _setLoading(true);
    _clearError();
    try {
      final user = await getProfileUseCase.execute();
      _currentUser = user;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String pharmacyName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await updateProfileUseCase.execute(
        name: name,
        pharmacyName: pharmacyName,
        phoneNumber: phoneNumber,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await changePasswordUseCase.execute(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
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
