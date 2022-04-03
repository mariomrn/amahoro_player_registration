import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Player extends StatelessWidget{

  Player({required this.firstName, required this.lastName, required this.birthday, required this.playerID});

  String firstName;
  String lastName;
  DateTime birthday;
  int playerID;

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called users that references the firestore collection
    CollectionReference players = FirebaseFirestore.instance.collection('player');

    Future<void> addPlayer() {
      // Call the user's CollectionReference to add a new user
      return players
          .add({
        'firstName': firstName, // John Doe
        'lastName': lastName, // Stokes and Sons
        'birthday': birthday // 42
      })
          .then((value) => print("Player Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return TextButton(
      onPressed: addPlayer,
      child: const Text(
        "Add Player",
      ),
    );
  }
}