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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF1871D), 
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF1871D), 
            foregroundColor: Colors.white, 
            elevation: 4,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // 3. Definindo a cor do Botão Flutuante (o '+')
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF1871D), // Laranja no botão
            foregroundColor: Colors.white, // Ícone '+' em branco
          ),

          // 4. Definindo a cor da Barra de Navegação
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: const Color(0xFFF1871D), // Ícone selecionado Laranja
            unselectedItemColor: Colors.grey[600], // Ícone não selecionado Cinza
          ),

          // (Opcional) Botões normais
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1871D),
              foregroundColor: Colors.white,
            ),
          ),

          useMaterial3: true,
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