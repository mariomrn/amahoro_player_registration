import 'dart:typed_data';
import 'package:amahoro_player_registration/screens/widgets/basicWidgets.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:amahoro_player_registration/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool dateGotSelected = false;
  XFile? pickedImage;
  Uint8List? imageBytes;
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
  late Future _futureGetInitial;
  DateTime date = DateTime(2016, 10, 26);
  DateTime birthdayDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _futureGetInitial = getInitial();
  }

  Future getInitial() async {
    getLeagues();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BasicWidgets.buildTitle('Leagues'),
              FutureBuilder(
                future: _futureGetInitial,
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
                            selectedColor: kAmahoroColorMaterial.shade700,
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
              BasicWidgets.buildTitle('Seasons'),
              FutureBuilder(
                future: _futureGetInitial,
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
                        seasonsTitleList
                            .length, //seasonsTitleList.length + 1 for the add choice chip to appear
                        (int index) {
                          if (index == seasonsTitleList.length) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ChoiceChip(
                                selectedColor:
                                    const Color.fromRGBO(163, 119, 101, 0),
                                labelStyle: kDefaultTextStyle.copyWith(
                                    color: Colors.white),
                                backgroundColor: Colors.grey.shade200,
                                label: Icon(
                                  Icons.add,
                                  color: kAmahoroColorMaterial.shade700,
                                  size: 15,
                                ),
                                selected: true,
                                onSelected: (bool selected) {
                                  setState(() {
                                    buildShowDialog(
                                        context,
                                        'Season',
                                        leagueCollectionRef
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
                              selectedColor: kAmahoroColorMaterial.shade700,
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
              BasicWidgets.buildTitle('Teams'),
              FutureBuilder(
                future: _futureGetInitial,
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
                        teamsTitleList
                            .length, //teamsTitleList.length + 1 for the add choice chip to appear
                        (int index) {
                          if (index == teamsTitleList.length) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ChoiceChip(
                                selectedColor:
                                    const Color.fromRGBO(163, 119, 101, 0),
                                labelStyle: kDefaultTextStyle.copyWith(
                                    color: Colors.white),
                                backgroundColor: Colors.grey.shade200,
                                label: Icon(
                                  Icons.add,
                                  color: kAmahoroColorMaterial.shade700,
                                  size: 15,
                                ),
                                selected: true,
                                onSelected: (bool selected) {
                                  setState(() {
                                    buildShowDialog(
                                        context,
                                        'Team',
                                        leagueCollectionRef
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
                              selectedColor: kAmahoroColorMaterial.shade700,
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
                                  selectedTeam = index;
                                  docID3 = teamsDocumentList[selectedTeam];
                                  print(docID3);
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
              BasicWidgets.buildTitle('Profile Picture'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: kAmahoroColorMaterial,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: imageBytes != null
                              ? Image.memory(imageBytes!).image
                              : null,
                          radius: 48,
                          child: imageBytes != null
                              ? Container()
                              : const Icon(
                                  Icons.person,
                                  color: kAmahoroColorMaterial,
                                ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'Add Photo',
                      style: kDefaultTextStyle.copyWith(
                          color: kAmahoroColorMaterial.shade700),
                    ),
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      pickedImage = await _picker.pickImage(
                          source: ImageSource.camera,
                          maxHeight: 640,
                          maxWidth: 480,
                          imageQuality: 80);
                      if (pickedImage == null) {
                        return;
                      }
                      if (pickedImage != null) {
                        imageBytes = await pickedImage?.readAsBytes();
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
              BasicWidgets.buildTitle('Last Name'),
              TextField(controller: lastNameController, inputFormatters: [
                UpperCaseTextFormatter(),
              ]),
              BasicWidgets.buildTitle('First Name'),
              TextField(
                controller: firstNameController,
              ),
              BasicWidgets.buildTitle('Date Of Birth'),
              //This is the new date picker carousel and replaces old crusty google date picker
              CupertinoButton(
                // Display a CupertinoDatePicker in date picker mode.
                onPressed: () {
                  _showDateDialog(
                    CupertinoDatePicker(
                      dateOrder: DatePickerDateOrder.dmy,
                      initialDateTime: date,
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      // This is called when the user changes the date.
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() => birthdayDate = newDate);
                      },
                    ),
                  );
                  dateGotSelected = true;
                },
                child: Text(
                  dateGotSelected
                      ? '${birthdayDate.day}.${birthdayDate.month}.${birthdayDate.year}'
                      : 'no date selected',
                  style: kDefaultTextStyle.copyWith(
                      color: dateGotSelected
                          ? Colors.grey.shade900
                          : Colors.grey.shade500),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30),
                child: Row(
                  children: [
                    _inProgress
                        ? Container()
                        : Expanded(
                            child: Container(
                              height: 40,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  primary: informationIsComplete()
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  backgroundColor: informationIsComplete()
                                      ? kAmahoroColorMaterial.shade700
                                      : Colors.grey.shade400,
                                ),
                                child: Text(
                                  'Submit Player',
                                  style: kDefaultTextStyle.copyWith(
                                      color: Colors.white),
                                ),
                                onPressed: informationIsComplete()
                                    ? () {
                                        addPlayer();
                                      }
                                    : null,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetValues() {
    firstNameController.clear();
    lastNameController.clear();
    birthdayDate = DateTime.now();
    dateGotSelected = false;
    pickedImage = null;
    imageBytes = null;
  }

  bool informationIsComplete() {
    return dateGotSelected &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        (imageBytes != null) &&
        docID3.length > 1;
  }

  void _showDateDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context, String title,
      CollectionReference collectionReference) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController tempController = TextEditingController();
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
                      'title': tempController.text,
                    })
                    .then((value) => print("Season Added"))
                    .catchError((error) => print("Failed to add user: $error"))
                    .then((value) => tempController.dispose());
                Navigator.pop(context);
                setState(() {
                  getLeagues().then((value1) => getSeasons(value1)
                      .then((value2) => getTeams(value1, value2)));
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

  bool _inProgress = false;

  Future<void> addPlayer() async {
    setState(() {
      _inProgress = true;
    });
    print('docID3');
    print(docID3);
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    int birthday = birthdayDate.millisecondsSinceEpoch;
    String storageRef =
        'players/$docID1/${firstName + lastName + birthday.toString()}';
    await storage.ref(storageRef).putData(imageBytes!);
    return leagueCollectionRef
        .doc(docID1)
        .collection('season')
        .doc(docID2)
        .collection('teams')
        .doc(docID3)
        .collection('players')
        .add({
          'firstName': firstName,
          'lastName': lastName,
          'birthday': birthday,
          'photoURL': storageRef,
        })
        .then((value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Upload Success')));
        })
        .then((value) => setState(() {
              _inProgress = false;
              resetValues();
            }))
        .catchError((error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Fail')));
        });
  }

  Future getLeagues() async {
    try {
      leagueDocumentList.clear();
      leagueTitleList.clear();
      await leagueCollectionRef.get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          leagueDocumentList.add(result.id);
          leagueTitleList.add(result.data());
        }
        docID1 = leagueDocumentList[selectedLeague];
        getSeasons(docID1);
      });
      return docID1;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getSeasons(String docID) async {
    try {
      seasonsTitleList.clear();
      seasonsDocumentList.clear();
      teamsTitleList.clear();
      teamsDocumentList.clear();
      await leagueCollectionRef
          .doc(docID)
          .collection('season')
          .get()
          .then((querySnapshot) {
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
      teamsTitleList.clear();
      teamsDocumentList.clear();
      docID3 = '';
      await leagueCollectionRef
          .doc(docID1)
          .collection('season')
          .doc(docID2)
          .collection('teams')
          .get()
          .then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          teamsTitleList.add(result.data());
          teamsDocumentList.add(result.id);
        }
      });
      setState(() {
        if (teamsDocumentList.isNotEmpty) {
          docID3 = teamsDocumentList[selectedTeam];
        }
      });
      return teamsTitleList;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
