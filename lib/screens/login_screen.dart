// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:projetoflutter/db/database_helper.dart';
import 'package:projetoflutter/screens/home_screen.dart';
import 'package:projetoflutter/screens/register_screen.dart';
import 'package:projetoflutter/theme/colors.dart'; // Nossas cores

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final user = await DatabaseHelper.instance.login(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Login com sucesso! Navega para a HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Erro no login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail ou senha inválidos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fundo Gradiente (Azul)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryLightColor, primaryDarkColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            // Cartão branco para o formulário
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone/Logo (Placeholder)
                      const Icon(
                        Icons.pets, // Ícone de patinha
                        color: primaryDarkColor,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Campo de E-mail
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Insira seu e-mail' : null,
                      ),
                      const SizedBox(height: 16),
                      // Campo de Senha
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) =>
                            value!.isEmpty ? 'Insira sua senha' : null,
                      ),
                      const SizedBox(height: 32),
                      // Botão Entrar (Amarelo)
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 16),
                      // Botão de texto para Cadastro
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Não tem uma conta? Cadastre-se',
                          style: TextStyle(color: primaryDarkColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}