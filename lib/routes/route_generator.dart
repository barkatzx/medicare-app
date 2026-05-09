import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/screens/products/product_detail_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/pending_approval_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/categories_screen.dart';
import '../presentation/screens/categories/category_products_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/home/trending_screen.dart';
import '../presentation/screens/cart/cart_screen.dart';
import '../presentation/screens/cart/checkout_screen.dart';
import '../presentation/screens/orders/my_orders_screen.dart';
import '../presentation/screens/orders/order_detail_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/profile/change_password_screen.dart';
import '../presentation/screens/profile/addresses_screen.dart';
import '../presentation/screens/notifications/notifications_screen.dart';
import 'app_routes.dart';
import 'auth_guard.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.pendingApproval:
        return MaterialPageRoute(builder: (_) => const PendingApprovalScreen());
      case AppRoutes.productDetail:
        return MaterialPageRoute(
          builder: (_) => const ProductDetailScreen(),
          settings: settings,
        );

      // Protected Routes
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const HomeScreen()),
        );
      case AppRoutes.categories:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const CategoriesScreen()),
        );
      case AppRoutes.categoryProducts:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(
            CategoryProductsScreen(
              categoryId: args['id'] as String,
              categoryName: args['name'] as String,
            ),
          ),
        );
      case AppRoutes.trending:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const TrendingScreen()),
        );
      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const CartScreen()),
        );
      case AppRoutes.checkout:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const CheckoutScreen()),
        );
      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const SearchScreen()),
        );
      case AppRoutes.myOrders:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const MyOrdersScreen()),
        );
      case AppRoutes.orderDetail:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const OrderDetailScreen()),
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const ProfileScreen()),
        );
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const EditProfileScreen()),
        );
      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const ChangePasswordScreen()),
        );
      case AppRoutes.addresses:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const AddressesScreen()),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const NotificationsScreen()),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
