// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:pet_center/models/user.dart'; 
import 'package:pet_center/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pet_center/screens/main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para todos os campos do usuário
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _sobreController = TextEditingController();

  bool _isLoading = false;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####', // Máscara para celular brasileiro
    filter: {"#": RegExp(r'[0-9]')}, // Permite apenas números
  );

  Future<void> _performRegistration() async {

    // 1. Valida o formulário ANTES de fazer qualquer coisa
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Se o formulário não for válido, PARA AQUI.
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final newUser = User(
      nome: _nomeController.text,
      email: _emailController.text,
      senha: _senhaController.text,
      telefone: _telefoneController.text,
      cidade: _cidadeController.text,
      sobre: _sobreController.text,
    );

    try {
      // 2. Tenta registrar (a função que modificamos, que NÃO loga)
      final success = await authProvider.register(newUser);

      // --- CORREÇÃO DO BUG 2 (MODAL) ---
      if (success && mounted) {
        // 3. SE DER SUCESSO, CHAMA O MODAL DE SUCESSO
        _showSuccessDialog();
      } else if (!success && mounted) {
        // 4. Se der erro (ex: e-mail duplicado)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail já cadastrado. Tente um e-mail diferente.'),
            backgroundColor: Colors.red,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    // Limpa os controladores quando a tela for destruída
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _cidadeController.dispose();
    _sobreController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cadastro Realizado!'),
          content: const SingleChildScrollView(
            child: Text('Sua conta foi criada com sucesso.\n\nClique em "OK" para entrar.'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                // 1. Fecha SÓ o dialog
                Navigator.of(dialogContext).pop(); 

                setState(() => _isLoading = true); // Mostra um loading

                // 2. Faz o login
                final success = await authProvider.login(
                  _emailController.text,
                  _senhaController.text,
                );

                setState(() => _isLoading = false); // Para o loading

                // 3. SE O LOGIN DER CERTO...
                if (success && mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(),
                    ),
                    (route) => false,
                  );

                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Falha ao logar automaticamente. Tente da tela de login.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  // Volta para a tela de login
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta (Instituição/Pessoal)'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crie seu Perfil',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // --- Campos Obrigatórios ---
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome (ou Nome da Instituição) *'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail (para login) *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo obrigatório';
                    // Validador de e-mail mais forte (Regex)
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(labelText: 'Senha *'),
                  obscureText: true, // Esconde a senha
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Campo obrigatório';
                    if (value.length < 8) return 'Senha deve ter no mínimo 8 caracteres';
                    // Força a ter pelo menos uma letra E um número
                    if (!RegExp(r'(?=.*[A-Za-z])').hasMatch(value)) {
                      return 'Senha deve ter pelo menos uma letra';
                    }
                    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                      return 'Senha deve ter pelo menos um número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- Campos Opcionais (mas importantes para o perfil) ---
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(labelText: 'Telefone (para contato)'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMaskFormatter],
                
                  validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Telefone é obrigatório';
                      }
                      // Checa se a máscara foi preenchida
                      if (value.length != '(##) #####-####'.length) {
                        return 'Telefone incompleto';
                      }
                      return null;
                    },
                ),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(labelText: 'Cidade / Estado'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sobreController,
                  decoration: const InputDecoration(labelText: 'Sobre (uma breve descrição)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Botão de Cadastro
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _performRegistration,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cadastrar e Entrar'),
                      ),
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Volta para o login
                  child: const Text('Já tenho uma conta. Fazer Login'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}