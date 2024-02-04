
import 'dart:typed_data';
import 'package:amahoro_player_registration/screens/player-detail-screen.dart';
import 'package:amahoro_player_registration/screens/widgets/basicWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/textStyles.dart';
import 'package:screenshot/screenshot.dart';

class ViewPlayerScreen extends StatefulWidget {
  const ViewPlayerScreen({Key? key}) : super(key: key);

  @override
  _ViewPlayerScreenState createState() => _ViewPlayerScreenState();
}

class _ViewPlayerScreenState extends State<ViewPlayerScreen> {
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
  late String currentSeason;
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

  @override
  void initState() {
    super.initState();
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
        selectedSeason = seasonsDocumentList.length-1;
        docID2 = seasonsDocumentList[selectedSeason];
        //selectedSeason = seasonsTitleList[selectedSeason];
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
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        GestureDetector playerCard = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute(dataList[index], playerDocumentList[index], leagueTitleList[selectedLeague]["title"], teamsTitleList[selectedTeam]["title"], leagueDocumentList[selectedLeague], seasonsDocumentList[selectedSeason], teamsDocumentList[selectedTeam], teamsTitleList, teamsDocumentList,)),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row (
                children: [
                  Text(dataList[index]["firstName"],
                      style: kDefaultTextStyle.copyWith(color: Colors.grey.shade800)),
                  Text(' ',
                      style: kDefaultTextStyle),
                  Text(dataList[index]["lastName"],
                      style: kDefaultTextStyle.copyWith(color: Colors.grey.shade800)),
                ],
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        );
        playerCardList.add(playerCard);
        return playerCard;
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: BasicWidgets.buildTitle('Leagues')),
                      ],
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
                              seasonsTitleList.length,
                              (int index) {
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
                                children: teamsTitleList.isEmpty
                                    ? [const Text('No Teams')]
                                    : List<Widget>.generate(
                                        teamsTitleList.length,
                                        (int index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: ChoiceChip(
                                              selectedColor: const Color.fromRGBO(
                                                  163, 119, 101, 1),
                                              labelStyle: selectedTeam == index
                                                  ? kDefaultTextStyle.copyWith(
                                                      color: Colors.white)
                                                  : kDefaultTextStyle.copyWith(
                                                      color: Colors.grey.shade600),
                                              backgroundColor: Colors.grey.shade200,
                                              label: Text(
                                                  teamsTitleList[index]['title']),
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
                                          );
                                        },
                                      ).toList()),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    BasicWidgets.buildTitle('Members'),
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
                              ? Center(child: const Text('No Members registered'))
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