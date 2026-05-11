import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // We only need authProvider for the initial route
    final authProvider = ref.watch(authProviderNotifier);

    return MaterialApp(
      title: 'MediCare PLC',
      debugShowCheckedModeBanner: false,
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
            : (authProvider.pendingApprovalMessage != null || authProvider.isPendingApproval)
                ? AppRoutes.pendingApproval
                : AppRoutes.login,
        onGenerateRoute: RouteGenerator.generateRoute,
      );
  }
}
