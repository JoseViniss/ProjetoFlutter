// models/user_model.dart

class User {
  final int? id;
  final String email;
  final String password; // No mundo real, isso seria "hash", mas para a faculdade, texto puro está ok.

  User({
    this.id,
    required this.email,
    required this.password,
  });

  // Mapeia para o banco de dados (colunas em português)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'senha': password, // Coluna 'senha' no BD
    };
  }

  // Mapeia do banco de dados para o objeto
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['senha'] as String, // Coluna 'senha' no BD
    );
  }
}