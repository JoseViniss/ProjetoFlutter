
class Breed {
  final String id;
  final String name;

  Breed({required this.id, required this.name});

  // "Tradutor" para converter o JSON da API em um objeto Breed
  factory Breed.fromMap(Map<String, dynamic> map) {
    return Breed(
      id: map['id'].toString(), // O ID pode vir como int, então convertemos
      name: map['name'] as String,
    );
  }
}