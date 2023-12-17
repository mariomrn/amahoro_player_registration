import 'dart:typed_data';
import 'package:amahoro_player_registration/screens/player-detail-screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/textStyles.dart';
import 'package:screenshot/screenshot.dart';

class ViewPlayerScreen2 extends StatefulWidget {
  const ViewPlayerScreen2({Key? key}) : super(key: key);

  @override
  _ViewPlayerScreenState2 createState() => _ViewPlayerScreenState2();
}

class _ViewPlayerScreenState2 extends State<ViewPlayerScreen2> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference leagueCollectionRef =
      FirebaseFirestore.instance.collection("league");
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  List leagueTitleList = [];
  List leagueDocumentList = [];
  List seasonsTitleList = [];
  List seasonsDocumentList = [];
  List teamsTitleList = [];
  List teamsDocumentList = [];
  int selectedLeague = 0;
  int selectedSeason = 0;
  int selectedTeam = 0;
  late String currentLeague;
  String currentSeason = "Placeholder";
  late String currentTeam;
  String docID1 = "SCj8y26uZv0o5HVffb4j";
  String docID2 = "1SVxOxjFnOHZzAKhRJ0y";
  String docID3 = "";
  late Future _futureGetInitial;
  List playerList = [];
  List playerDocumentList = [];
  List<Widget> playerCardList = [];
  List<ScreenshotController> screenshotControllerList = [];
  final pdf = pw.Document();
  IconData sortingIcon = Icons.history;

  @override
  void initState() {
    super.initState();
    selectedLeague = 0; // Set the initial league
    selectedSeason = 0; // Set the initial season
    playerList.clear();
    _futureGetInitial = getInitial();
  }

  Future getInitial() async {
    getLeagues();
  }

  Future getLeagues() async {
    try {
      playerList.clear();
      leagueDocumentList.clear();
      leagueTitleList.clear();
      await leagueCollectionRef.get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          leagueDocumentList.add(result.id);
          leagueTitleList.add(result.data());
        }
        docID1 = leagueDocumentList[selectedLeague];
        getSeasons(docID1);
        //currentLeague = leagueTitleList[selectedLeague];
      });
      return docID1;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getSeasons(String docID) async {
    try {
      playerList.clear();
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
        if (seasonsTitleList.isNotEmpty) {
          docID2 = seasonsDocumentList[selectedSeason];
          currentSeason = seasonsTitleList[selectedSeason]['title'];
          getTeams(docID1, docID2);
        }
      });

      return seasonsTitleList;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getTeams(String docID1, String docID2) async {
    try {
      playerList.clear();
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
        playerList.clear();
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
      return docID3;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getData() async {
    playerList.clear();
    if (docID3.isEmpty) {
      return null;
    }
    try {
      await leagueCollectionRef
          .doc(docID1)
          .collection('season')
          .doc(docID2)
          .collection('teams')
          .doc(docID3)
          .collection('players')
          .get()
          .then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          playerList.add(result.data());
          playerDocumentList.add(result.id);
        }
      });
      print(playerList);
      return playerList;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future<String> downloadURL(String storageRef) async {
    String downloadURL = await storage.ref(storageRef).getDownloadURL();
    return downloadURL;
  }

  Widget buildItems(dataList) => ListView.separated(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dataList.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) => Container(height: 10,),
      itemBuilder: (BuildContext context, int index) {
        GestureDetector playerCard = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SecondRoute(
                        dataList[index],
                        playerDocumentList[index],
                        leagueTitleList[selectedLeague]["title"],
                        teamsTitleList[selectedTeam]["title"],
                        leagueDocumentList[selectedLeague],
                        seasonsDocumentList[selectedSeason],
                        teamsDocumentList[selectedTeam],
                        teamsTitleList,
                        teamsDocumentList,
                      )),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Row(
                children: [
                  Text(
                    dataList[index]["firstName"],
                  ),
                  Text(' ', style: kDefaultTextStyle),
                  Text(
                    dataList[index]["lastName"],
                  ),
                ],
              ),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      dataList[index]["birthday"]))),
            ),
          ),
        );
        playerCardList.add(playerCard);
        return playerCard;
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, top: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kimisagara',
                  style: kDefaultTextStyleHeader,
                ),
                FutureBuilder(
                  future: _futureGetInitial,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        "Something went wrong",
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      return DropdownButton(
                        underline: Container(),
                        iconEnabledColor: Colors.transparent,
                        value: currentSeason,
                        style: kDefaultTextStyle15pt.copyWith(
                            color: Color(0xff413028)),
                        items: seasonsTitleList
                            .map<DropdownMenuItem<String>>((dynamic listitem) {
                          return DropdownMenuItem<String>(
                            value: listitem['title'],
                            child: Text(listitem['title']),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          // Find the index of the selected item's title in seasonsTitleList
                          int selectedIndex = seasonsTitleList
                              .indexWhere((item) => item['title'] == value);
                          // Do something with the index (e.g., save it to a variable)
                          setState(() {
                            currentSeason = value!;
                            docID2 = seasonsDocumentList[selectedIndex];
                            getTeams(docID1, docID2);
                          });
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
            SizedBox(height: 20,),
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
                        children: teamsTitleList.isEmpty
                            ? [const Text('No Teams')]
                            : List<Widget>.generate(
                                teamsTitleList.length,
                                (int index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: selectedTeam == index ? const Color(0xff211814) : Colors.transparent,
                                          width: selectedTeam == index ? 3.0 : 0.0, // Thickness of the border
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ChoiceChip(
                                        disabledColor: const Color(0x00211814),
                                        selectedColor: const Color(0x00211814),
                                        labelStyle: selectedTeam == index
                                            ? kTeamSelectionTextStyle.copyWith(
                                                color: const Color(0xff211814), fontWeight: FontWeight.w700,)
                                            : kTeamSelectionTextStyle.copyWith(
                                                color: Colors.grey.shade500),
                                        backgroundColor: const Color(0x00211814),
                                        label:
                                            Text(teamsTitleList[index]['title']),
                                        selected: selectedTeam == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            selectedTeam = index;
                                            print('before' + docID3);
                                            docID3 =
                                                teamsDocumentList[selectedTeam];
                                            print('after' + docID3);
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ).toList()),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            Container(height: 2, decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff211814),
                  width: 2.0, // Thickness of the border
                ),
              ),
            ),),
            const SizedBox(height: 10,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Colors.grey.shade200,
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.transparent, // Set the border color
                              width: 2, // Adjust the border width as needed
                            ), // You can change the color as needed
                          ),
                          child: IconButton(
                            icon: Icon(sortingIcon, color: Colors.brown,),
                            onPressed: () {
                              setState(() {
                                if (sortingIcon == Icons.history)
                                  sortingIcon = Icons.sort_by_alpha;
                                else
                                  sortingIcon = Icons.history;
                              });
                              // Handle sorting button press
                              print('Sorting button pressed');
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                    FutureBuilder(
                      future: getData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                            "Something went wrong",
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          screenshotControllerList.clear();
                          playerCardList.clear();
                          return playerList.isEmpty
                              ? const Center(
                                  child: Text('No Members registered'))
                              : buildItems(playerList);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Uint8List> playerCardImages = [];
}
