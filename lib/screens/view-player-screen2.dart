import 'dart:typed_data';
import 'package:amahoro_player_registration/screens/player-detail-screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/colors.dart';
import '../theme/textStyles.dart';
import 'package:screenshot/screenshot.dart';

import 'add-player-specific.dart';

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
  //seasonList[].id = docID
  //seasonList[].data()
  List seasonsList = [];
  //List seasonsDocumentList = [];
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
      seasonsList.clear();
      //seasonsTitleList.clear();
      //seasonsDocumentList.clear();
      teamsTitleList.clear();
      teamsDocumentList.clear();
      await leagueCollectionRef
          .doc(docID)
          .collection('season')
          .get()
          .then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          seasonsList.add(result);
          //seasonsDocumentList.add(result.id);
          seasonsList.sort((b, a) {
            final timestampA = a.data()['timestamp'];
            final timestampB = b.data()['timestamp'];

            // Compare timestamps
            return timestampA.compareTo(timestampB);
          });
        }
      });
      setState(() {
        if (seasonsList.isNotEmpty) {
          docID2 = seasonsList[selectedSeason].id;
          currentSeason = seasonsList[selectedSeason].data()['title'];
          getTeams(docID1, docID2);
        }
      });

      return seasonsList;
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
      separatorBuilder: (BuildContext context, int index) => Container(
            height: 10,
          ),
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
                        seasonsList[selectedSeason].id,
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
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              height: 120, // Adjust the height according to your design
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: FutureBuilder(
                      future: downloadURL(dataList[index]["photoURL"]),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasError) {
                          return const Icon(
                            Icons.person,
                            color: kAmahoroColorMaterial,
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 47,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    Image.network(snapshot.data!).image,
                                radius:
                                    45, // Adjust the radius according to your design
                              ),
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              dataList[index]["firstName"],
                              style: kNameTS,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dataList[index]["lastName"],
                              style: kNameTS,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          DateFormat('dd.MM.yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              dataList[index]["birthday"],
                            ),
                          ),
                          style: kBirthdayTS,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                            color: const Color(0xff413028)),
                        items:
                            seasonsList.map<DropdownMenuItem<String>>((season) {
                          final title = season.data()[
                              'title']; // Adjust this based on your data structure
                          return DropdownMenuItem<String>(
                            value: title
                                .toString(), // Assuming title is a String, adjust accordingly
                            child: Text(title
                                .toString()), // Assuming title is a String, adjust accordingly
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          // Find the index of the selected item's title in seasonsTitleList
                          int selectedIndex = seasonsList.indexWhere(
                              (season) => season.data()['title'] == value);
                          // Do something with the index (e.g., save it to a variable)
                          setState(() {
                            currentSeason = value!;
                            docID2 = seasonsList[selectedIndex]
                                .id; // Adjust this based on your actual data structure
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
            const SizedBox(
              height: 20,
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
                                          color: selectedTeam == index
                                              ? const Color(0xff211814)
                                              : Colors.transparent,
                                          width: selectedTeam == index
                                              ? 3.0
                                              : 0.0, // Thickness of the border
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
                                                color: const Color(0xff211814),
                                                fontWeight: FontWeight.w700,
                                              )
                                            : kTeamSelectionTextStyle.copyWith(
                                                color: Colors.grey.shade500),
                                        backgroundColor:
                                            const Color(0x00211814),
                                        label: Text(
                                            teamsTitleList[index]['title']),
                                        selected: selectedTeam == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            selectedTeam = index;
                                            docID3 =
                                                teamsDocumentList[selectedTeam];
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
            Container(
              height: 2,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff211814),
                    width: 2.0, // Thickness of the border
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8.0),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.transparent, // Set the border color
                              width: 2, // Adjust the border width as needed
                            ), // You can change the color as needed
                          ),
                          child: IconButton(
                            icon: Icon(
                              sortingIcon,
                              color: Colors.brown,
                            ),
                            onPressed: () {
                              setState(() {
                                if (sortingIcon == Icons.history) {
                                  sortingIcon = Icons.sort_by_alpha;
                                } else {
                                  sortingIcon = Icons.history;
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Colors.grey.shade200,
                            ),
                            child: const TextField(
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
                            color: Colors.brown,
                            border: Border.all(
                              color: Colors.transparent, // Set the border color
                              width: 2, // Adjust the border width as needed
                            ), // You can change the color as needed
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => APS(leagueDocumentList[selectedLeague], seasonsList[selectedSeason].id, teamsDocumentList[selectedTeam])),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0),
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
                              ? Column(
                                  children: const [
                                    Center(
                                        child: Text('No Members registered')),
                                  ],
                                )
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
