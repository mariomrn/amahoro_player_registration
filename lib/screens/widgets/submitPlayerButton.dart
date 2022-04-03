// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class SubmitPlayerButton extends StatelessWidget{
//
//   Future<void> addPlayer() {
//     CollectionReference players = FirebaseFirestore.instance.collection('player');
//     // Call the user's CollectionReference to add a new user
//     return players
//         .add({
//       'firstName': firstName, // John Doe
//       'lastName': lastName, // Stokes and Sons
//       'birthday': birthday // 42
//     })
//         .then((value) => print("Player Added"))
//         .catchError((error) => print("Failed to add user: $error"));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Create a CollectionReference called users that references the firestore collection
//     return TextButton(
//       onPressed: addPlayer,
//       child: const Text(
//         "Add Player",
//       ),
//     );
//   }
//
// }