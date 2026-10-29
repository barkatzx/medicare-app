import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final navigatorObservers = <NavigatorObserver>[];
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await Firebase.initializeApp();
      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);
      navigatorObservers.add(
        FirebaseAnalyticsObserver(analytics: analytics),
      );
    } catch (error, stackTrace) {
      debugPrint('Firebase Analytics initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Global Error Handling for Production
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled platform error: $error');
    debugPrintStack(stackTrace: stack);
    return false;
  };

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  await container.read(authProviderNotifier).initialize();

  final pushNotifications = container.read(pushNotificationServiceProvider);
  container
      .read(authProviderNotifier)
      .attachPushNotificationService(pushNotifications);
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await pushNotifications.initialize(
        authenticated: container.read(authProviderNotifier).isLoggedIn &&
            container.read(authProviderNotifier).isCustomer,
      );
    } catch (error, stackTrace) {
      debugPrint('Firebase Messaging initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(navigatorObservers: navigatorObservers),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    pushNotifications.flushPendingNavigation();
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, required this.navigatorObservers});

  final List<NavigatorObserver> navigatorObservers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authProviderNotifier);

    return MaterialApp(
      title: 'MediCare PLC',
      debugShowCheckedModeBanner: false,
      navigatorObservers: navigatorObservers,
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: CustomTheme.backgroundColor,
        fontFamily: CustomTheme.primaryFontFamily,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
            height: 1.3,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            height: 1.4,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1F2937),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F2937),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            height: 1.4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      initialRoute: authProvider.isLoggedIn && authProvider.isCustomer
          ? AppRoutes.home
          : (authProvider.pendingApprovalMessage != null ||
                authProvider.isPendingApproval)
          ? AppRoutes.pendingApproval
          : AppRoutes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
