import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import '../presentation/screens/auth/pending_approval_screen.dart';

class AuthGuard {
  static Widget protectRoute(Widget child) {
    return Consumer(
      builder: (context, ref, _) {
        final authProvider = ref.watch(authProviderNotifier);
        
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verifying account...'),
                ],
              ),
            ),
          );
        }

        // Show pending approval screen
        if (authProvider.isPendingApproval) {
          return const PendingApprovalScreen();
        }

        // Show login screen if not authenticated
        if (!authProvider.isLoggedIn || !authProvider.isCustomer) {
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }

        return child;
      },
    );
  }
}
