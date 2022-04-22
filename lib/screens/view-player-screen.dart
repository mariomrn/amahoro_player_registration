import 'dart:html' as html;
import 'dart:typed_data';
import 'package:amahoro_player_registration/screens/widgets/basicWidgets.dart';
import 'package:amahoro_player_registration/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
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
  List<Widget> playerCardList = [];
  ScreenshotController scontroller = ScreenshotController();

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
    print(docID3);
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

  //before calling buildItems screenshotcontroller list should be emptied
  List<ScreenshotController> screenshotControllerList = [];

  Widget buildItems(dataList) => ListView.separated(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dataList.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        ScreenshotController screenshotController = ScreenshotController();
        Widget playerCard = Screenshot(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: kAmahoroColorMaterial,
                  width: 10,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              width: 430,
              height: 260,
              child: Column(
                children: [
                  Expanded(
                      flex: 2,
                      child: Center(
                          child: Text(
                        leagueTitleList[selectedLeague]['title'].toUpperCase(),
                        style: kPlayerCardLeagueTS,
                      ))), //leagueTitleList[selectedLeague]['title']
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(teamsTitleList[selectedTeam]['title'],
                              style:
                                  kPlayerCardSubtitleTS), //teamsTitleList[selectedTeam]['title']
                          Text(seasonsTitleList[selectedSeason]['title'],
                              style:
                                  kPlayerCardSubtitleTS), //seasonsTitleList[selectedSeason]['title']
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(dataList[index]["firstName"],
                                  style: kPlayerCardTextTS),
                              Text(dataList[index]["lastName"],
                                  style: kPlayerCardTextTS),
                              Text(
                                  DateFormat('dd.MM.yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          dataList[index]["birthday"])),
                                  style:
                                      kPlayerCardTextTS), //dataList[index]["birthday"]
                            ],
                          ),
                        ),
                        Expanded(
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: kAmahoroColorMaterial,
                            child: FutureBuilder(
                              future: downloadURL(dataList[index]["photoURL"]),
                              builder:
                                  (context, AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasError) {
                                  return const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    //backgroundImage: imageBytes!=null ? Image.memory(imageBytes!).image : null,
                                    radius: 48,
                                    child: Icon(
                                      Icons.person,
                                      color: kAmahoroColorMaterial,
                                    ),
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: Image.network(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ).image,
                                    radius: 48,
                                  );
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            controller: screenshotController);
        playerCardList.add(playerCard);
        screenshotControllerList.add(screenshotController);
        return playerCard;
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: playerCardList.isNotEmpty
                          ? Colors.white
                          : Colors.grey.shade600,
                      backgroundColor: playerCardList.isNotEmpty
                          ? const Color.fromRGBO(163, 119, 101, 1)
                          : Colors.grey.shade400,
                    ),
                    child: Text(
                      'Open as PDF',
                      style: kDefaultTextStyle.copyWith(color: Colors.white),
                    ),
                    onPressed: () async {
                      await createPDF();
                    },
                  ),
                ),
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
                    return playerList.isEmpty
                        ? Text('No Player found')
                        : buildItems(playerList);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  final pdf = pw.Document();
  var anchor;

  savePDF() async {
    Uint8List pdfInBytes = await pdf.save();
    final blob = html.Blob([pdfInBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor =
    // html.document.createElement('a') as html.AnchorElement
    //   ..href = url
    //   ..style.display = 'none'
    //   ..download = 'some_name.pdf';
    // html.document.body?.children.add(anchor);
    // anchor.click();
    // html.document.body?.children.remove(anchor);
    // html.Url.revokeObjectUrl(url);
    // that was not helpful:
    // html.AnchorElement anchorElement =  html.AnchorElement(href: url);
    // anchorElement.download = url;
    // anchorElement.click();
    // anchor = html.document.createElement('a') as html.AnchorElement
    //   ..href = url
    //   ..style.display = 'none'
    //   ..download = 'pdf.pdf';
    // html.document.body?.children.add(anchor);
    // anchor.click();
    html.window.open(url, 'PlaceholderName');
  }

  List<Uint8List> playerCardImages = [];
  capturePlayerCards() async {
    playerCardImages.clear();
    for (ScreenshotController screenshotController
        in screenshotControllerList) {
      await screenshotController
          .capture()
          .then((value) => playerCardImages.add(value!));
    }
    print('length ' + playerCardImages.length.toString());
    return playerCardImages;
  }

  createPDF() async {
    await capturePlayerCards()
        .then(
          (capturedImage) {
            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (context) {
                  return pw.Column(
                    children: buildRows(),
                  );
                },
              ),
            );
          },
        )
        .then((value) => savePDF());
  }

  List<pw.Row> buildRows() {
    List<pw.Row> playercardRows = [];
    List<Uint8List> playerCardtemp = [];
    for (var playerCardImage in playerCardImages) {
      playerCardtemp.add(playerCardImage);
      if (playerCardtemp.length > 1) {
        playercardRows.add(
          pw.Row(
            children: [
              for (var playercardimage in playerCardtemp)
                pw.Container(
                  height: 100,
                  width: 250,
                  child: pw.Image(
                    pw.MemoryImage(playercardimage),
                    fit: pw.BoxFit.contain,
                  ),
                ),
            ],
          ),
        );
        playerCardtemp.clear();
      }
    }
    return playercardRows;
  }
}
