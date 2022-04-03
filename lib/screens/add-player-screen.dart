import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({Key? key}) : super(key: key);

  @override
  _AddPlayerScreenState createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextField(
            controller: firstNameController,
          ),
          TextField(
            controller: lastNameController,
          ),
          TextButton(
            child: const Text('Choose Birthday'),
            onPressed: () {
              _selectDate(context);
            },
          ),
          Text(selectedDate.toIso8601String()),
          TextButton(
            child: const Text('Press me'),
            onPressed: () {
              addPlayer();
              firstNameController.clear();
              lastNameController.clear();
              selectedDate = DateTime.now();
            },
          ),
        ],
      ),
    );
  }

  Future<void> addPlayer() {
    CollectionReference players = FirebaseFirestore.instance.collection('player');
    // Call the user's CollectionReference to add a new user
    return players
        .add({
      'firstName': firstNameController.text, // John Doe
      'lastName': lastNameController.text, // Stokes and Sons
      'birthday': selectedDate // 42
    })
        .then((value) => print("Player Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

}
