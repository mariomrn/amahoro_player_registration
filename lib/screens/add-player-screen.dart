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
  CollectionReference leagueCollectionRef =
      FirebaseFirestore.instance.collection("league");
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool dateGotSelected = false;
  List leagueTitleList = [];
  List leagueDocumentList = [];
  List seasonsTitleList = [];
  List seasonsDocumentList = [];
  List teamsTitleList = [];
  List teamsDocumentList = [];
  int selectedLeague = 0;
  int selectedSeason = 0;
  int selectedTeam = 0;
  String docID1 = "";
  String docID2 = "";
  String docID3 = "";
  late Future _futureGetLeagues;
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: kTitleTextStyle,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _futureGetLeagues = getLeagues();
    _futureGetSeasons = getSeasons('SCj8y26uZv0o5HVffb4j');
    _futureGetTeams = getTeams('SCj8y26uZv0o5HVffb4j', '1SVxOxjFnOHZzAKhRJ0y');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle('Leagues'),
            FutureBuilder(
              future: _futureGetLeagues,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Something went wrong",
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return Wrap(
                      children: List<Widget>.generate(
                    leagueTitleList.length,
                    (int index) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ChoiceChip(
                          selectedColor:
                              const Color.fromRGBO(163, 119, 101, 1),
                          labelStyle: selectedLeague == index
                              ? kDefaultTextStyle.copyWith(
                                  color: Colors.white)
                              : kDefaultTextStyle.copyWith(
                                  color: Colors.grey.shade600),
                          backgroundColor: Colors.grey.shade200,
                          label: Text(leagueTitleList[index]['title']),
                          selected: selectedLeague == index,
                          onSelected: (bool selected) {
                            setState(() {
                              docID1 = leagueDocumentList[index];
                              getSeasons(docID1);
                              selectedLeague = index;
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
            buildTitle('Seasons'),
            FutureBuilder(
              future: _futureGetSeasons,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Something went wrong",
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List<Widget>.generate(
                      seasonsTitleList.length +1 ,
                      (int index) {
                        if (index == seasonsTitleList.length) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ChoiceChip(
                              selectedColor: const Color.fromRGBO(163, 119, 101, 0),
                              labelStyle: kDefaultTextStyle.copyWith(
                                  color: Colors.white),
                              backgroundColor: Colors.grey.shade200,
                              label: const Icon(
                                Icons.add,
                                color: Color.fromRGBO(163, 119, 101, 1),
                                size: 15,
                              ),
                              selected: true,
                              onSelected: (bool selected) {
                                setState(() {
                                  buildShowDialog(context, 'Season', leagueCollectionRef
                                      .doc(docID1)
                                      .collection('season'));
                                });
                              },
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ChoiceChip(
                            selectedColor:
                                const Color.fromRGBO(163, 119, 101, 1),
                            labelStyle: selectedSeason == index
                                ? kDefaultTextStyle.copyWith(
                                    color: Colors.white)
                                : kDefaultTextStyle.copyWith(
                                    color: Colors.grey.shade600),
                            backgroundColor: Colors.grey.shade200,
                            label: Text(seasonsTitleList[index]['title']),
                            selected: selectedSeason == index,
                            onSelected: (bool selected) {
                              setState(() {
                                docID2 = seasonsDocumentList[index];
                                getTeams(docID1, docID2);
                                selectedSeason = index;
                              });
                            },
                          ),
                        );
                      },
                    ).toList()),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            buildTitle('Teams'),
            FutureBuilder(
              future: _futureGetTeams,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Something went wrong",
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List<Widget>.generate(
                      teamsTitleList.length + 1,
                      (int index) {
                        if (index == teamsTitleList.length) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ChoiceChip(
                              selectedColor: const Color.fromRGBO(163, 119, 101, 0),
                              labelStyle: kDefaultTextStyle.copyWith(
                                  color: Colors.white),
                              backgroundColor: Colors.grey.shade200,
                              label: const Icon(
                                Icons.add,
                                color: Color.fromRGBO(163, 119, 101, 1),
                                size: 15,
                              ),
                              selected: true,
                              onSelected: (bool selected) {
                                setState(() {
                                  buildShowDialog(context, 'Team', leagueCollectionRef
                                      .doc(docID1)
                                      .collection('season')
                                      .doc(docID2)
                                      .collection('teams'));
                                });
                              },
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ChoiceChip(
                            selectedColor:
                                const Color.fromRGBO(163, 119, 101, 1),
                            labelStyle: selectedTeam == index
                                ? kDefaultTextStyle.copyWith(
                                    color: Colors.white)
                                : kDefaultTextStyle.copyWith(
                                    color: Colors.grey.shade600),
                            backgroundColor: Colors.grey.shade200,
                            label: Text(teamsTitleList[index]['title']),
                            selected: selectedTeam == index,
                            onSelected: (bool selected) {
                              setState(() {
                                docID3 = teamsDocumentList[selectedTeam];
                                selectedTeam = index;
                              });
                            },
                          ),
                        );
                      },
                    ).toList()),
                  );
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
                      : 'no date selected',
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
            Expanded(child: Container(),),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: !dateGotSelected &&
                              firstNameController.text.isEmpty &&
                              lastNameController.text.isEmpty
                          ? Colors.grey.shade600
                          : Colors.white,
                      backgroundColor: !dateGotSelected &&
                              firstNameController.text.isEmpty &&
                              lastNameController.text.isEmpty
                          ? Colors.grey.shade400
                          : const Color.fromRGBO(163, 119, 101, 1),
                    ),
                    child: Text(
                      'Submit Player',
                      style: kDefaultTextStyle.copyWith(color: Colors.white),
                    ),
                    onPressed: !dateGotSelected &&
                            firstNameController.text.isEmpty &&
                            lastNameController.text.isEmpty
                        ? null
                        : () {
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
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context, String title, CollectionReference collectionReference) {
    return showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    TextEditingController tempController =
                                    TextEditingController();
                                    return SimpleDialog(
                                      title: Text('Add a ' + title),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: TextField(
                                            controller: tempController,
                                          ),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () {
                                            collectionReference
                                                .add({
                                              'title':
                                              tempController
                                                  .text,
                                            })
                                                .then((value) =>
                                            print("Season Added")).catchError((error) => print("Failed to add user: $error")).then((value) => tempController.dispose());
                                            Navigator.pop(context);
                                            setState(() {
                                              getLeagues().then((value1) => getSeasons(value1).then((value2) => getTeams(value1, value2)));
                                            });
                                          },
                                          child: Text('Add ' + title),
                                        ),
                                        SimpleDialogOption(
                                          onPressed: () {
                                            tempController.dispose();
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
  }

  Future<void> addPlayer() {
    print('docID3');
    print(docID3);
    return leagueCollectionRef
        .doc(docID1)
        .collection('season')
        .doc(docID2)
        .collection('teams')
        .doc(docID3)
        .collection('players')
        .add({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'birthday': selectedDate.millisecondsSinceEpoch,
        })
        .then((value) => print("Player Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future getLeagues() async {
    try {
      await leagueCollectionRef.get().then((querySnapshot) {
        leagueDocumentList.clear();
        leagueTitleList.clear();
        for (var result in querySnapshot.docs) {
          leagueDocumentList.add(result.id);
          leagueTitleList.add(result.data());
        }
        docID1 = leagueDocumentList[selectedLeague];
      });
      return docID1;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getSeasons(String docID) async {
    try {
      await leagueCollectionRef
          .doc(docID)
          .collection('season')
          .get()
          .then((querySnapshot) {
        seasonsTitleList.clear();
        seasonsDocumentList.clear();
        for (var result in querySnapshot.docs) {
          seasonsTitleList.add(result.data());
          seasonsDocumentList.add(result.id);
        }
      });
      setState(() {
        docID2 = seasonsDocumentList[selectedSeason];
        getTeams(docID1, docID2);
      });
      return seasonsTitleList;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getTeams(String docID1, String docID2) async {
    try {
      await leagueCollectionRef
          .doc(docID1)
          .collection('season')
          .doc(docID2)
          .collection('teams')
          .get()
          .then((querySnapshot) {
        teamsTitleList.clear();
        teamsDocumentList.clear();
        for (var result in querySnapshot.docs) {
          teamsTitleList.add(result.data());
          teamsDocumentList.add(result.id);
        }
      });
      setState(() {
        docID3 = teamsDocumentList[selectedTeam];
      });
      return teamsTitleList;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }
}
