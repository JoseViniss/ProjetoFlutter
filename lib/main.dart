// lib/main.dart

import 'package:flutter/material.dart';
import 'package:projetoflutter/screens/login_screen.dart'; // <<< VAMOS MUDAR A TELA INICIAL
import 'package:projetoflutter/theme/colors.dart'; // <<< IMPORTANDO NOSSAS CORES

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoção de Animais',
      // AQUI ESTÁ A MÁGICA DO DESIGN
      theme: ThemeData(
        // Esquema de cores principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor, // Azul claro como cor primária
          primary: primaryColor,
          secondary: accentColor, // Amarelo vivo como secundário/acento
          brightness: Brightness.light,
        ),
        
        // Tema da AppBar (barra no topo)
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white, // Cor do texto e ícones
          elevation: 4,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Tema do Botão Flutuante (Amarelo!)
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.black, // Cor do ícone '+'
        ),

        // Tema dos Botões Elevados (Amarelo!)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor, // Fundo amarelo
            foregroundColor: Colors.black, // Texto preto
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // Botões arredondados
            ),
          ),
        ),
        
        // Tema dos campos de texto
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none, // Sem borda
          ),
          filled: true,
          fillColor: Colors.grey[100], // Fundo cinza claro
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),

        useMaterial3: true,
      ),
      // AQUI MUDAMOS A TELA INICIAL
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}