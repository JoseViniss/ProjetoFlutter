import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/dog.dart';
import '../widgets/dog_card.dart';
import 'register_dog_screen.dart';
import 'package:provider/provider.dart';              
import 'package:pet_center/providers/auth_provider.dart';

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

  // lib/screens/swipe_screen.dart

  Future<void> loadDogs() async {
    setState(() => isLoading = true);

    final newList = await db.getDogs();    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id;

    if (currentUserId != null) {
      newList.removeWhere((dog) => dog.userId == currentUserId);
    }

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
            icon: const Icon(Icons.add),
            onPressed: () async { 

              final bool? foiSalvo = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterDogScreen()),
              );

              if (foiSalvo == true) {
                loadDogs();
              }
            },
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
                            key: Key('${currentDog.id?.toString() ?? 'dog'}_${DateTime.now().millisecondsSinceEpoch}'),
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
