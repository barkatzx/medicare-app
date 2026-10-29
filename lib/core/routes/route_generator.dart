import 'package:flutter/material.dart';
import 'package:medicare_app/features/screen/product_detail_screen.dart';
import '../../features/screen/notifications_screen.dart';
import '../../features/screen/notification_detail_screen.dart';
import '../../features/screen/login_screen.dart';
import '../../features/screen/register_screen.dart';
import '../../features/screen/forgot_password_screen.dart';
import '../../features/screen/pending_approval_screen.dart';
import '../../features/screen/home_screen.dart';
import '../../features/screen/categories_screen.dart';
import '../../features/screen/category_products_screen.dart';
import '../../features/screen/search_screen.dart';
import '../../features/screen/trending_screen.dart';
import '../../features/screen/cart_screen.dart';
import '../../features/screen/checkout_screen.dart';
import '../../features/screen/my_orders_screen.dart';
import '../../features/screen/order_detail_screen.dart';
import '../../features/screen/profile_screen.dart';
import '../../features/screen/edit_profile_screen.dart';
import '../../features/screen/change_password_screen.dart';
import '../../features/screen/addresses_screen.dart';
import '../../features/screen/about_screen.dart';
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
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const NotificationsScreen()),
          settings: settings,
        );
      case AppRoutes.notificationDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) =>
              AuthGuard.protectRoute(NotificationDetailScreen(id: id)),
          settings: settings,
        );
      case AppRoutes.myOrders:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const MyOrdersScreen()),
          settings: settings,
        );
      case AppRoutes.orderDetail:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const OrderDetailScreen()),
          settings: settings,
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const ProfileScreen()),
          settings: settings,
        );
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const EditProfileScreen()),
          settings: settings,
        );
      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const ChangePasswordScreen()),
          settings: settings,
        );
      case AppRoutes.addresses:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const AddressesScreen()),
          settings: settings,
        );
      case AppRoutes.about:
        return MaterialPageRoute(
          builder: (_) => AuthGuard.protectRoute(const AboutScreen()),
          settings: settings,
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
