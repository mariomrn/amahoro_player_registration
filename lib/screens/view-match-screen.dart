import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/colors.dart';
import '../theme/textStyles.dart';
import 'package:screenshot/screenshot.dart';

class ViewMatchScreen extends StatefulWidget {
  const ViewMatchScreen({Key? key}) : super(key: key);

  @override
  State<ViewMatchScreen> createState() => _ViewMatchScreenState();
}

class _ViewMatchScreenState extends State<ViewMatchScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  CollectionReference leagueCollectionRef =
      FirebaseFirestore.instance.collection("league");
  CollectionReference testSeasonCollectionRef = FirebaseFirestore.instance
      .collection("league")
      .doc('bCQQ0U7Ir8zSZFDU6Kv6')
      .collection('season'); //test for Kimisagara
  var leagueDocID = 'bCQQ0U7Ir8zSZFDU6Kv6'; // Kimisagara
  var seasonDocID = 'eRmGgNQrCYmO2f9iXzeb'; // Spring 24
  var teamDocID = '';
  bool _inProgress = false;
  late Future _futureGetInitial;
  List<String> teamsNameList = [];
  List teamsDataList = [];
  List teamsIDList = [];
  List<ScreenshotController> screenshotControllerList = [];
  List type = ['goal', 'yellowCard', 'redCard', 'change'];
  List<Widget> teamCardList = [];
  TextEditingController _teamNameController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed.
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //selectedLeague = 0; // Set the initial league
    //selectedSeason = 1; // Set the initial season
    teamsDataList.clear();
    teamsNameList.clear();
    _futureGetInitial = getInitial();
  }

  Future getInitial() async {
    //super.initState();
    setState(() {
      getTeams();
    });
  }

  Future getTeams() async {
    try {
      teamsNameList.clear();
      teamsDataList.clear();
      teamsIDList.clear();
      teamDocID = '';
      await leagueCollectionRef
          .doc(leagueDocID)
          .collection('season')
          .doc(seasonDocID)
          .collection('teams')
          .get()
          .then((querySnapshot) {
        teamsDataList.clear();
        teamsNameList.clear();
        for (var result in querySnapshot.docs) {
          teamsNameList.add(result.data()['title']);
          teamsDataList.add(result.data());
          teamsIDList.add(result.id);
        }
      });
      return teamsDataList;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future<dynamic> _showAddTeamDialog(BuildContext context,
      String title /*,CollectionReference collectionReference*/) {
    // Reset the controller's text to empty before opening the dialog
    _teamNameController.text = '';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Add a ' + title),
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _teamNameController,
                decoration: InputDecoration(hintText: title + " name"),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                if (_teamNameController.text.isNotEmpty) {
                  _addTeam(_teamNameController);
                  Navigator.pop(context);
                }
              },
              child: Text('Add ' + title),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTeam(TextEditingController teamNameController) async {
    setState(() {
      _inProgress = true;
    });

    String teamName = teamNameController.text;
    String storageRef = 'teams/$leagueDocID/$teamName';
    //await storage.ref(storageRef).putData(imageBytes!);
    return leagueCollectionRef
        .doc(leagueDocID)
        .collection('season')
        .doc(seasonDocID)
        .collection('teams')
        .add({
          'title': teamName,
          'matches played': 0,
          'wins': 0,
          'draws': 0,
          'losses': 0,
          'goals scored': 0,
          'goals received': 0,
          'logoURL': storageRef,
        })
        .then((value) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Upload Success')));
        })
        .then((value) => setState(() {
              _inProgress = false;
              //resetValues();
            }))
        .catchError((error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Fail')));
        });
  }

  Future<void> _createMatchplan(BuildContext context) async {
    //print(teamsNameList);
    List<String> alleMannschaften = List.from(teamsNameList);
    if (alleMannschaften.length % 2 != 0) {
      // Hinzufügen eines Dummy-Teams, wenn die Anzahl der Teams ungerade ist
      alleMannschaften.add('Dummy-Team');
    }
    int anzahlMannschaften = alleMannschaften.length;
    int anzahlSpieltage = anzahlMannschaften - 1;

    // Aufteilen der Mannschaften in zwei Gruppen
    List<String> gruppeHeim =
        alleMannschaften.sublist(0, anzahlMannschaften ~/ 2);
    List<String> gruppeAuswaerts =
        alleMannschaften.sublist(anzahlMannschaften ~/ 2).reversed.toList();

    for (int spieltag = 0; spieltag < anzahlSpieltage; spieltag++) {
      String spieltagTitle = 'Match day ${spieltag + 1}';
      DocumentReference spieltagRef = await testSeasonCollectionRef
          .doc(seasonDocID)
          .collection('matchdays')
          .add({
        'title': spieltagTitle,
      });

      for (int spiel = 0; spiel < gruppeHeim.length; spiel++) {
        String heimmannschaft = gruppeHeim[spiel];
        String auswaertsmannschaft = gruppeAuswaerts[spiel];

        // Überspringen, wenn eines der Teams das Dummy-Team ist
        if (heimmannschaft == 'Dummy-Team' ||
            auswaertsmannschaft == 'Dummy-Team') continue;

        spieltagRef.collection('matches').add({
          'home': heimmannschaft,
          'away': auswaertsmannschaft,
          'goalshome': 0,
          'goalsaway': 0,
          'title': 'Match' + (spiel + 1).toString(),
        });
      }

      // Rotieren der Mannschaften für den nächsten Spieltag
      if (spieltag < anzahlSpieltage - 1) {
        gruppeHeim.insert(1, gruppeAuswaerts.removeAt(0));
        gruppeAuswaerts.add(gruppeHeim.removeLast());
      }
    }
  }

  Future<void> _deleteAllMatches() async {
    CollectionReference spieleCollection =
        FirebaseFirestore.instance.collection('matchdays');

    // Abrufen aller Spieltage-Dokumente
    QuerySnapshot spieltageSnapshot = await spieleCollection.get();

    // Durchlaufen aller Spieltage-Dokumente
    for (var spieltag in spieltageSnapshot.docs) {
      // Abrufen aller Spiele-Dokumente für jeden Spieltag
      QuerySnapshot spieleSnapshot =
          await spieleCollection.doc(spieltag.id).collection('matches').get();

      // Durchlaufen und Löschen aller Spiele-Dokumente
      for (var spiel in spieleSnapshot.docs) {
        await spieleCollection
            .doc(spieltag.id)
            .collection('matches')
            .doc(spiel.id)
            .delete();
      }
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
        GestureDetector teamCard = GestureDetector(
          behavior: HitTestBehavior.opaque,
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
            child: Container(
              height: 120, // Adjust the height according to your design
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    child: FutureBuilder(
                      future: downloadURL(dataList[index]["logoURL"]),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasError) {
                          return const Icon(
                            Icons.people,
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
                          Text(
                            dataList[index]["title"],
                            style: kNameTS,
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        );
        teamCardList.add(teamCard);
        return teamCard;
      });

  void speichereEreignis(
      String liga,
      String saison,
      String spieltag,
      String spiel,
      String typ,
      String spieler,
      String team,
      int minute,
      bool istHeimTeam) {
    testSeasonCollectionRef
        .doc(seasonDocID)
        .collection('matchdays')
        .doc(spieltag)
        .collection('matches')
        .doc(spiel)
        .collection('events')
        .add({
      'type': typ,
      'player': spieler,
      'team': team,
      'minute': minute,
    });

    aktualisiereSpielstand(liga, saison, spieltag, spiel, istHeimTeam);
  }

  void aktualisiereSpielstand(String liga, String saison, String spieltag,
      String spiel, bool istHeimMannschaft) {
    DocumentReference spielRef = FirebaseFirestore.instance
        .collection('leagues')
        .doc(liga)
        .collection('season')
        .doc(saison)
        .collection('matchdays')
        .doc(spieltag)
      ..collection('matches').doc(spiel);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot spielSnapshot = await transaction.get(spielRef);

      var spielDaten = spielSnapshot.data() as Map<String, dynamic>;
      int toreHeim = spielDaten['homegoals'] ?? 0;
      int toreAuswaerts = spielDaten['awaygoals'] ?? 0;

      if (istHeimMannschaft) {
        toreHeim += 1;
        FirebaseFirestore.instance
            .collection('leagues')
            .doc(liga)
            .collection('season')
            .doc(saison)
            .collection('matchdays')
            .doc(spieltag)
            .collection('matches')
            .doc(spiel)
            .update({
          'homegoals': toreHeim,
        });
      } else {
        toreAuswaerts += 1;

        FirebaseFirestore.instance
            .collection('leagues')
            .doc(liga)
            .collection('season')
            .doc(saison)
            .collection('matchdays')
            .doc(spieltag)
            .collection('matches')
            .doc(spiel)
            .update({
          'awaygoals': toreAuswaerts,
        });
      }
    });
    // Hier könnte man auch die Mannschafts- und Spielerstatistiken aktualisieren
  }

  Future<void> aktualisiereMannschaftsstatistiken(
      String liga,
      String mannschaftsId,
      bool istHeimmannschaft,
      int erzielteTore,
      int kassierteTore) async {
    DocumentReference mannschaftRef = FirebaseFirestore.instance
        .collection('leagues')
        .doc(leagueDocID)
        .collection('season')
        .doc(seasonDocID)
        .collection('teams')
        .doc(mannschaftsId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot mannschaftSnapshot =
          await transaction.get(mannschaftRef);

      if (!mannschaftSnapshot.exists) {
        throw Exception("Mannschaft nicht gefunden");
      }
      // Stellen Sie sicher, dass spielerSnapshot.data() eine Map ist
      var mannschaftDaten = mannschaftSnapshot.data() as Map<String, dynamic>;
      int spieleGespielt = mannschaftDaten['matches played'] ?? 0;
      int siege = mannschaftDaten['wins'] ?? 0;
      int unentschieden = mannschaftDaten['draws'] ?? 0;
      int niederlagen = mannschaftDaten['losses'] ?? 0;
      int toreGeschossen = mannschaftDaten['goals scored'] ?? 0;
      int toreErhalten = mannschaftDaten['goals received'] ?? 0;

      spieleGespielt += 1;
      toreGeschossen += erzielteTore;
      toreErhalten += kassierteTore;

      if (erzielteTore > kassierteTore) {
        siege += 1; // Sieg
      } else if (erzielteTore == kassierteTore) {
        unentschieden += 1; // Unentschieden
      } else {
        niederlagen += 1; // Niederlage
      }

      transaction.update(mannschaftRef, {
        'matches played': spieleGespielt,
        'wins': siege,
        'draws': unentschieden,
        'losses': niederlagen,
        'goals scored': toreGeschossen,
        'goals received': toreErhalten
      });
    });
  }

  Future<void> aktualisiereSpielerstatistiken(
      String liga, String spielerId, String ereignisTyp) async {
    DocumentReference spielerRef = FirebaseFirestore.instance
        .collection('Ligen')
        .doc(liga)
        .collection('Spieler')
        .doc(spielerId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot spielerSnapshot = await transaction.get(spielerRef);

      if (!spielerSnapshot.exists) {
        throw Exception("Spieler nicht gefunden");
      }
      // Stellen Sie sicher, dass spielerSnapshot.data() eine Map ist
      var spielerDaten = spielerSnapshot.data() as Map<String, dynamic>;

      // Jetzt können Sie sicher auf die Daten mit dem []-Operator zugreifen
      int tore = spielerDaten['goals'] ?? 0;
      int gelbeKarten = spielerDaten['yellow cards'] ?? 0;
      int roteKarten = spielerDaten['red cards'] ?? 0;

      if (ereignisTyp == 'Tor') {
        tore += 1;
      } else if (ereignisTyp == 'GelbeKarte') {
        gelbeKarten += 1;
      } else if (ereignisTyp == 'RoteKarte') {
        roteKarten += 1;
      }

      transaction.update(spielerRef,
          {'Tore': tore, 'gelbekarten': gelbeKarten, 'rotekarten': roteKarten});
    });
  }

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
                Text(
                  'Season 2024',
                  style: kDefaultTextStyle15pt,
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddTeamDialog(context, 'team'),
                  child: Icon(Icons.add),
                ),
                ElevatedButton(
                  onPressed: () => _createMatchplan(context),
                  child: Icon(Icons.calendar_today),
                ),
              ],
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
                    FutureBuilder(
                      future: getTeams(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                            "Something went wrong",
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          screenshotControllerList.clear();
                          teamCardList.clear();
                          return teamsDataList.isEmpty
                              ? const Center(
                                  child: Text('No Members registered'))
                              : buildItems(teamsDataList);
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
}
