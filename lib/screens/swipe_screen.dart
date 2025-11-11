import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/dog.dart';
import '../widgets/dog_card.dart';
import 'register_dog_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);
  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final DBService db = DBService();

  List<Dog> dogs = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDogs();
  }

  Future<void> loadDogs() async {
    setState(() => isLoading = true);

    final list = await db.getDogs();

    if (list.isEmpty) {
      final exampleDogs = [
        Dog(
          name: 'Max',
          photoUrl:
              'https://images.pexels.com/photos/1458916/pexels-photo-1458916.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          breed: 'Golden Retriever',
          sex: 'Macho',
          age: 2,
          size: 'Grande',
          color: 'Dourado',
          description:
              'Amigo e brincalhão. Adora bolinhas e passear no parque!',
          city: 'São Paulo',
          healthStatus: 'Saudável',
          vaccinationStatus: 'Vacinado',
          isCastrated: true, 
        ),
        Dog(
          name: 'Luna',
          photoUrl:
              'https://images.pexels.com/photos/58997/example-dog-galloping-meadow-58997.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          breed: 'SRD (Vira-lata)',
          sex: 'Fêmea', 
          age: 1,
          size: 'Médio',
          color: 'Caramelo',
          description:
              'Dócil e um pouco tímida, mas muito carinhosa quando confia.',
          city: 'Rio de Janeiro',
          healthStatus: 'Saudável', 
          vaccinationStatus: 'Pendente', 
          isCastrated: false, 
        ),
        Dog(
          name: 'Bolinha',
          photoUrl:
              'https://images.pexels.com/photos/3361739/pexels-photo-3361739.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          breed: 'Pug',
          age: 4,
          size: 'Pequeno',
          color: 'Preto', 
          sex: 'Macho', 
          description: 'Um bolinha de pelos roncadora. Adora dormir no colo.',
          city: 'Belo Horizonte',
          healthStatus: 'Alergia de pele', 
          vaccinationStatus: 'Vacinado', 
          isCastrated: true, 
        ),
      ];

      for (final dog in exampleDogs) {
        await db.insertDog(dog);
      }
    }

    final newList = await db.getDogs();
    setState(() {
      dogs = newList;
      currentIndex = 0;
      isLoading = false; 
    });
  }

  void _nextCard(bool liked) async {
    if (currentIndex >= dogs.length) return;

    if (liked) {
      final dog = dogs[currentIndex];
      if (dog.id != null) {
        await db.addFavorite(dog.id!);
      }
    }

    setState(() => currentIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final currentDog = (currentIndex < dogs.length) ? dogs[currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('AdopetMatch'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegisterDogScreen()),
            ).then((_) => loadDogs()),
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : currentDog == null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Sem mais cães disponíveis por enquanto. Tente novamente mais tarde!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Dismissible(
                            key: Key(currentDog.id?.toString() ??
                                'dog_$currentIndex'),
                            onDismissed: (direction) {
                              final liked =
                                  direction == DismissDirection.startToEnd;
                              _nextCard(liked);
                            },
                            background: Container(
                              decoration: BoxDecoration(
                                color: primaryColor.withAlpha(204),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.favorite,
                                  color: Colors.white, size: 60),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 30),
                            ),
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 60),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 30),
                            ),
                            child: DogCard(dog: currentDog),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FloatingActionButton(
                            heroTag: 'skip_button',
                            onPressed: () => _nextCard(false),
                            child: Icon(Icons.close),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          FloatingActionButton(
                            heroTag: 'like_button',
                            onPressed: () => _nextCard(true),
                            child: Icon(Icons.favorite),
                            backgroundColor: primaryColor, 
                          ),
                        ],
                      ),
                      SizedBox(height: 12)
                    ],
                  ),
      ),
    );
  }
}
