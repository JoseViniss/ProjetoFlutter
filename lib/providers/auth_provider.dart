// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/db_service.dart';

class AuthProvider extends ChangeNotifier {
  final DBService dbService;
  
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider({required this.dbService});

  // Função de Login
  Future<bool> login(String email, String password) async {
    try {
      final user = await dbService.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners(); // Avisa a todas as telas "Ei, o usuário mudou!"
        return true;
      }
      return false;
    } catch (e) {
      print("Erro no login: $e");
      return false;
    }
  }

  Future<bool> register(User user) async {
    try {
      // Cria o usuário no banco
      await dbService.createUser(user);
      return true;
      
    } catch (e) {
      print("Erro no registro: $e");
      return false;
    }
  }
  // Função de Logout
  void logout() {
    _currentUser = null;
    notifyListeners(); // Avisa a todas as telas
  }

}