import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/shared_prefs_helper.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/address/data/repositories/address_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_auth_usecase.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';
import '../../features/products/presentation/providers/product_provider.dart';
import '../../features/categories/presentation/providers/category_provider.dart';
import '../../features/categories/presentation/providers/category_products_provider.dart';
import '../../features/home/presentation/providers/special_products_provider.dart';
import '../../features/address/presentation/providers/address_provider.dart';
import '../../features/orders/presentation/providers/order_provider.dart';

// Navigation Provider
class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

final navigationProvider = ChangeNotifierProvider<NavigationProvider>((ref) => NavigationProvider());

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

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    client: ref.watch(httpClientProvider),
    prefsHelper: ref.watch(sharedPrefsHelperProvider),
  );
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(
    client: ref.watch(httpClientProvider),
    prefsHelper: ref.watch(sharedPrefsHelperProvider),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
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

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(authRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ChangePasswordUseCase(repository: repository);
});

// ChangeNotifiers
final authProviderNotifier = ChangeNotifierProvider<AuthProvider>((ref) {
  final loginUC = ref.watch(loginUseCaseProvider);
  final registerUC = ref.watch(registerUseCaseProvider);
  final verifyUC = ref.watch(verifyAuthUseCaseProvider);
  final getProfileUC = ref.watch(getProfileUseCaseProvider);
  final updateProfileUC = ref.watch(updateProfileUseCaseProvider);
  final changePasswordUC = ref.watch(changePasswordUseCaseProvider);

  return AuthProvider(
    loginUseCase: loginUC,
    registerUseCase: registerUC,
    verifyAuthUseCase: verifyUC,
    getProfileUseCase: getProfileUC,
    updateProfileUseCase: updateProfileUC,
    changePasswordUseCase: changePasswordUC,
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

final categoryProviderNotifier = ChangeNotifierProvider<CategoryProvider>((ref) {
  return CategoryProvider(
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

final categoryProductsProviderFamily = ChangeNotifierProvider.autoDispose.family<CategoryProductsProvider, String>((ref, categoryId) {
  return CategoryProductsProvider(
    productRepository: ref.watch(productRepositoryProvider),
    categoryId: categoryId,
  );
});

final specialProductsProviderNotifier = ChangeNotifierProvider<SpecialProductsProvider>((ref) {
  return SpecialProductsProvider(
    productRepository: ref.watch(productRepositoryProvider),
  );
});

final addressProviderNotifier = ChangeNotifierProvider<AddressProvider>((ref) {
  return AddressProvider(
    addressRepository: ref.watch(addressRepositoryProvider),
  );
});

final orderProviderNotifier = ChangeNotifierProvider<OrderProvider>((ref) {
  return OrderProvider(
    orderRepository: ref.watch(orderRepositoryProvider),
  );
});
