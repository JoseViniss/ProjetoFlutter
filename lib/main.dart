import 'package:flutter/material.dart';

import 'package:pet_center/screens/login_screen.dart'; 
import 'package:pet_center/providers/auth_provider.dart';
import 'package:pet_center/services/db_service.dart';
import 'package:pet_center/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';
/* import 'package:pet_center/screens/swipe_screen.dart';
import 'package:pet_center/screens/dashboard_screen.dart';
import 'package:pet_center/screens/favorites_screen.dart';
import 'package:pet_center/screens/location_screen.dart';
import 'package:pet_center/screens/login_screen.dart';
import 'package:pet_center/screens/register_dog_screen.dart'; */

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DBService>(
          create: (_) => DBService(),
        ),
      
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(
            dbService: ctx.read<DBService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AdopetMatch',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
        routes: {
          '/home': (ctx) => const MainNavigationScreen(),
          '/login': (ctx) => const LoginScreen(),
        },
        
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isAuthenticated) {
          return const MainNavigationScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}