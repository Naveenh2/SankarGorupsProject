import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/auth_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/quote_provider.dart';
import 'services/quote_service.dart';
import 'services/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(AuthService()),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(FirestoreService()),
        ),
        ChangeNotifierProvider<QuoteProvider>(
          create: (_) => QuoteProvider(QuoteService()),
        ),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
