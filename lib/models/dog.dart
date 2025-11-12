class Dog {
  int? id;
  String name;
  String photoUrl;
  String breed; // Raça
  String sex; // Macho / Fêmea
  int age; // Idade
  String size; // Pequeno, Médio, Grande
  String color; // Cor
  String description; // A "bio"
  String city; // Cidade
  String healthStatus; // Ex: "Saudável", "Tratando doença de pele"
  String vaccinationStatus; // Ex: "Vacinado", "Pendente"
  bool isCastrated; // Castrado?
  double? latitude;
  double? longitude;
  final int userId;

  Dog({
    this.id,
    this.latitude,
    this.longitude,
    required this.userId,
    required this.name,
    required this.photoUrl,
    required this.breed,
    required this.sex,
    required this.age,
    required this.size,
    required this.color,
    required this.description,
    required this.city,
    required this.healthStatus,
    required this.vaccinationStatus,
    required this.isCastrated,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'longitude': longitude,
      'latitude': latitude,
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'breed': breed,
      'sex': sex,
      'age': age,
      'size': size,
      'color': color,
      'description': description,
      'city': city,
      'healthStatus': healthStatus,
      'vaccinationStatus': vaccinationStatus,
      'isCastrated': isCastrated ? 1 : 0, 
    };
  }

 
  factory Dog.fromMap(Map<String, dynamic> map) {
    return Dog(
      id: map['id'],
      longitude: map['longitude'] as double?,
      latitude: map['latitude'] as double?,
      userId: map['userId'] as int,
      name: map['name'],
      photoUrl: map['photoUrl'],
      breed: map['breed'],
      sex: map['sex'],
      age: map['age'],
      size: map['size'],
      color: map['color'],
      description: map['description'],
      city: map['city'],
      healthStatus: map['healthStatus'],
      vaccinationStatus: map['vaccinationStatus'],
      isCastrated: map['isCastrated'] == 1,
    );
  }
}