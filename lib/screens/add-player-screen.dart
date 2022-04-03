import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../theme/textStyles.dart';

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
  bool dateGotSelected = false;
  List<int> selectedPositions = [];
  List<String> positions = [
    'Goalkeeper',
    'Right Fullback',
    'Left Fullback',
    'Center Back',
    'Defending',
    'Right Midfielder',
    'Central',
    'Striker',
    'Attacking Midfielder',
    'Left Midfielder',
  ];

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2004),
      firstDate: DateTime(1980),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        dateGotSelected = true;
        selectedDate = selected;
      });
    }
  }

  Widget buildTitle(String title) {
    return Text(title.toUpperCase(), style: kTitleTextStyle,);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildTitle('First Name'),
            TextField(
              controller: firstNameController,
            ),
            buildTitle('Last Name'),
            TextField(
              controller: lastNameController,
            ),
            buildTitle('Date Of Birth'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateGotSelected
                      ? DateFormat('dd.MM.yyyy').format(selectedDate)
                      : '',
                  style: kDefaultTextStyle.copyWith(
                      color: dateGotSelected
                          ? Colors.grey.shade900
                          : Colors.grey.shade500),
                ),
                TextButton(
                  child: Text(
                    'Choose Birthday',
                    style: kDefaultTextStyle,
                  ),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ],
            ),
            buildTitle('Positions'),
            Wrap(
              children: List<Widget>.generate(
                positions.length,
                (int index) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ChoiceChip(
                      selectedColor: const Color.fromRGBO(163, 119, 101, 1),
                      labelStyle: selectedPositions.contains(index)
                          ? kDefaultTextStyle.copyWith(color: Colors.white)
                          : kDefaultTextStyle.copyWith(color: Colors.grey.shade600),
                      backgroundColor: Colors.grey.shade200,
                      label: Text(positions[index]),
                      selected: selectedPositions.contains(index),
                      onSelected: (bool selected) {
                        setState(() {
                          selectedPositions.contains(index)
                              ? selectedPositions.remove(index)
                              : selectedPositions.add(index);
                        });
                      },
                    ),
                  );
                },
              ).toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: const Color.fromRGBO(163, 119, 101, 1),
                  ),
                  child: Text('Submit Player', style: kDefaultTextStyle.copyWith(color: Colors.white),),
                  onPressed: () {
                    addPlayer();
                    setState(() {
                      firstNameController.clear();
                      lastNameController.clear();
                      selectedDate = DateTime.now();
                      dateGotSelected = false;
                      selectedPositions.clear();
                    });
                  },
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getPositions() {
    String result = '';
    for (int index in selectedPositions) {
      result = result + positions[index] + ", ";
    }
    return result;
  }

  Future<void> addPlayer() {
    CollectionReference players =
        FirebaseFirestore.instance.collection('player');
    // Call the user's CollectionReference to add a new user
    return players
        .add({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'birthday': selectedDate.millisecondsSinceEpoch,
          'playerID': DateTime.now().microsecondsSinceEpoch,
          'positions': getPositions(),
        })
        .then((value) => print("Player Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
