// lib/models/user.dart

class User {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final String? telefone;
  final String? cidade;
  final String? sobre;

  User({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.telefone,
    this.cidade,
    this.sobre,
  });

  User copyWith({
    int? id,
    String? nome,
    String? email,
    String? senha,
    String? telefone,
    String? cidade,
    String? sobre,
  }) {
    return User(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      telefone: telefone ?? this.telefone,
      cidade: cidade ?? this.cidade,
      sobre: sobre ?? this.sobre,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha, // NOTA: No mundo real, isso seria um HASH
      'telefone': telefone,
      'cidade': cidade,
      'sobre': sobre,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
      telefone: map['telefone'] as String?,
      cidade: map['cidade'] as String?,
      sobre: map['sobre'] as String?,
    );
  }
}