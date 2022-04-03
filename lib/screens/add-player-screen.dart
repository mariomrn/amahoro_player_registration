import 'package:amahoro_player_registration/models/player.dart';
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
          Player(firstName: 'Kimi', lastName: 'sagara', birthday: DateTime(2000), playerID: 912837,),
          TextButton(
            child: const Text('Press me'),
            onPressed: () {
              // Player p0 = Player(
              //   firstName: firstNameController.text,
              //   lastName: lastNameController.text,
              //   birthday: DateTime(2019),
              //   id: 1737168,
              // );
              //TODO: Hier muss der erzeugte Spieler in die Datenbank gespielt werden
              firstNameController.clear();
              lastNameController.clear();
            },
          ),
        ],
      ),
    );
  }
}
