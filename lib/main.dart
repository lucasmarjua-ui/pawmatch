import 'package:flutter/material.dart';
import 'models/dog_model.dart';
import 'screens/dog_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawMatch',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: DogProfileScreen(
        dog: Dog(
          id: '1',
          name: 'Rocky',
          breed: 'Golden Retriever',
          ageInMonths: 24,
          ownerName: 'Lucas',
          photoUrl: '',
          description: 'Friendly and playful, loves long walks.',
        ),
      ),
    );
  }
}