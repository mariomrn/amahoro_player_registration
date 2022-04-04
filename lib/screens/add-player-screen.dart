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
  final CollectionReference seasonsCollectionRef =
  FirebaseFirestore.instance.collection("seasons");
  CollectionReference teamsCollectionRef =
  FirebaseFirestore.instance.collection("teams");
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool dateGotSelected = false;
  List seasonsTitleList = [];
  List teamsList = [];
  List seasonsDocumentList = [];
  int selectedLeague = 0;
  int selectedTeam = 0;
  late Future _futureGetSeasons;
  late Future _futureGetTeams;

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
  void initState() {
    super.initState();
    _futureGetSeasons = getSeasons();
    _futureGetTeams = getTeams();
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
            buildTitle('Season'),
            FutureBuilder(
              future: _futureGetSeasons,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Something went wrong",
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return Wrap(
                    children: List<Widget>.generate(
                      seasonsTitleList.length,
                          (int index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ChoiceChip(
                            selectedColor: const Color.fromRGBO(163, 119, 101, 1),
                            labelStyle: selectedLeague==index
                                ? kDefaultTextStyle.copyWith(color: Colors.white)
                                : kDefaultTextStyle.copyWith(color: Colors.grey.shade600),
                            backgroundColor: Colors.grey.shade200,
                            label: Text(seasonsTitleList[index]['title']),
                            selected: selectedLeague==index,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedLeague=index;
                              });
                            },
                          ),
                        );
                      },
                    ).toList());
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            buildTitle('Team'),
            FutureBuilder(
              future: _futureGetTeams,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Something went wrong",
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return Wrap(
                      children: List<Widget>.generate(
                        teamsList[selectedLeague]['teams'].length,
                            (int index) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ChoiceChip(
                              selectedColor: const Color.fromRGBO(163, 119, 101, 1),
                              labelStyle: selectedTeam==index
                                  ? kDefaultTextStyle.copyWith(color: Colors.white)
                                  : kDefaultTextStyle.copyWith(color: Colors.grey.shade600),
                              backgroundColor: Colors.grey.shade200,
                              label: Text(teamsList[selectedLeague]['teams'][index]),
                              selected: selectedTeam==index,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedTeam=index;
                                });
                              },
                            ),
                          );
                        },
                      ).toList());
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
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
        })
        .then((value) => print("Player Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future getSeasons() async {
    try {
      await seasonsCollectionRef.get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          seasonsTitleList.add(result.data());
          print(seasonsTitleList);
        }
      });
      return seasonsTitleList;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getTeams() async {
    try {
      await teamsCollectionRef.get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          teamsList.add(result.data());
        }
        print(teamsList[selectedLeague]['teams']);
      });
      return teamsCollectionRef;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

}
