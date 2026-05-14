import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:medicare_app/core/services/notification_service.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

// Background task for notifications
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) return true;

      // Simple fetch for new notifications
      final response = await http.get(
        Uri.parse('https://medicare-server-9je0.onrender.com/v1/users/notifications?unreadOnly=true'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final latest = data.first;
          // Only show if it's new (could store last seen id in prefs)
          final lastId = prefs.getString('last_notif_id');
          if (latest['id'] != lastId) {
            await LocalNotificationService.initialize();
            await LocalNotificationService.showNotification(
              id: latest['id'].hashCode,
              title: latest['title'] ?? 'New Notification',
              body: latest['message'] ?? 'You have a new update from MediCare.',
            );
            await prefs.setString('last_notif_id', latest['id']);
          }
        }
      }
    } catch (e) {
      debugPrint('Background Task Error: $e');
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Handling for Production
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return true;
  };

  // Handle network issues on Wi-Fi/Broadband
  HttpOverrides.global = MyHttpOverrides();

  // Initialize Local Notifications
  await LocalNotificationService.initialize();

  // Initialize Background Workmanager
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  
  // Register periodic task (checks every 15 minutes)
  await Workmanager().registerPeriodicTask(
    "medicare_notif_task",
    "fetch_notifications",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  await container.read(authProviderNotifier).initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authProviderNotifier);

    return MaterialApp(
      title: 'MediCare PLC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: CustomTheme.backgroundColor,
          fontFamily: CustomTheme.primaryFontFamily,
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Outfit', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1F2937), letterSpacing: -0.5, height: 1.2),
            displayMedium: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1F2937), letterSpacing: -0.3, height: 1.3),
            displaySmall: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937), height: 1.4),
            headlineMedium: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937), height: 1.4),
            bodyLarge: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1F2937), height: 1.5),
            bodyMedium: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF6B7280), height: 1.5),
            bodySmall: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF9CA3AF), height: 1.5),
            labelLarge: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1F2937),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937), height: 1.4),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
            ),
          ),
        ),
        initialRoute: authProvider.isLoggedIn && authProvider.isCustomer
            ? AppRoutes.home
            : (authProvider.pendingApprovalMessage != null || authProvider.isPendingApproval)
                ? AppRoutes.pendingApproval
                : AppRoutes.login,
        onGenerateRoute: RouteGenerator.generateRoute,
      );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}
