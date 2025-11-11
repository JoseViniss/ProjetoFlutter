// models/animal_model.dart

class Animal {
  final int? id;
  final String name;
  final String species; 
  final int age; 

  Animal({
    this.id,
    required this.name,
    required this.species,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': name,
      'especie': species,
      'idade': age,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] as int?,
      name: map['nome'] as String,
      species: map['especie'] as String,
      age: map['idade'] as int,
    );
  }
}