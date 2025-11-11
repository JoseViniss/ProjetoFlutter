import 'package:flutter/material.dart';

import 'package:pet_center/screens/login_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   
    final Color primaryOrange = const Color(0xFFF1871D);

    return MaterialApp(
      title: 'AdopetMatch',
      debugShowCheckedModeBanner: false,
      
      
      theme: ThemeData(
        primaryColor: primaryOrange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryOrange,
          primary: primaryOrange, 
          secondary: primaryOrange,
        ),
        
        
        appBarTheme: AppBarTheme(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white, 
          centerTitle: true,
          elevation: 0,
        ),
       
        
       
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: primaryOrange,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
        
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}