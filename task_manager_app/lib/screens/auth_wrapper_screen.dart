import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_provider.dart';
import '../services/quote_provider.dart';
import '../services/task_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthWrapperScreen extends StatefulWidget {
  const AuthWrapperScreen({super.key});

  @override
  State<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends State<AuthWrapperScreen> {
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (BuildContext context, AuthProvider authProvider, _) {
        final String? userId = authProvider.user?.uid;
        final TaskProvider taskProvider = context.read<TaskProvider>();
        final QuoteProvider quoteProvider = context.read<QuoteProvider>();

        if (userId != null && userId != _lastUserId) {
          _lastUserId = userId;
          taskProvider.listenToTasks(userId);
          quoteProvider.fetchQuote();
        } else if (userId == null && _lastUserId != null) {
          _lastUserId = null;
          taskProvider.clear();
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
