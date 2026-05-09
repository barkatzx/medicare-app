import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/local/shared_prefs_helper.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/auth/verify_auth_usecase.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/cart_provider.dart';
import '../presentation/providers/notification_provider.dart';
import '../presentation/providers/product_provider.dart';

// Core
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final sharedPrefsHelperProvider = Provider<SharedPrefsHelper>((ref) {
  return SharedPrefsHelper(ref.watch(sharedPreferencesProvider));
});

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    client: ref.watch(httpClientProvider),
    sharedPreferencesHelper: ref.watch(sharedPrefsHelperProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    client: ref.watch(httpClientProvider),
    prefsHelper: ref.watch(sharedPrefsHelperProvider),
  );
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    client: ref.watch(httpClientProvider),
    prefsHelper: ref.watch(sharedPrefsHelperProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    client: ref.watch(httpClientProvider),
    prefsHelper: ref.watch(sharedPrefsHelperProvider),
  );
});

// Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final verifyAuthUseCaseProvider = Provider<VerifyAuthUseCase>((ref) {
  return VerifyAuthUseCase(ref.watch(authRepositoryProvider));
});

// ChangeNotifiers
final authProviderNotifier = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    verifyAuthUseCase: ref.watch(verifyAuthUseCaseProvider),
  );
});

final productProviderNotifier = ChangeNotifierProvider<ProductProvider>((ref) {
  return ProductProvider(
    productRepository: ref.watch(productRepositoryProvider),
  );
});

final cartProviderNotifier = ChangeNotifierProvider<CartProvider>((ref) {
  return CartProvider(
    cartRepository: ref.watch(cartRepositoryProvider),
  );
});

final notificationProviderNotifier = ChangeNotifierProvider<NotificationProvider>((ref) {
  return NotificationProvider(
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});
