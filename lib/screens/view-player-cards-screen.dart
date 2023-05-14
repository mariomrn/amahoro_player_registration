import 'dart:html' as html;
import 'dart:typed_data';
import 'package:amahoro_player_registration/screens/widgets/basicWidgets.dart';
import 'package:amahoro_player_registration/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/textStyles.dart';
import 'package:screenshot/screenshot.dart';

class ViewPlayerCards extends StatefulWidget {
  const ViewPlayerCards({Key? key}) : super(key: key);

  @override
  _ViewPlayerCardsState createState() => _ViewPlayerCardsState();
}

class _ViewPlayerCardsState extends State<ViewPlayerCards> {
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
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: leagueTitleList[selectedLeague]['title']=='Kabuye YL' ? Image.asset('assets/images/templateKabu.jpeg').image : Image.asset('assets/images/templateKimi.jpeg').image,),
                  color: Colors.white,
                ),
                width: 453,
                height: 260,
                child: Row(
                  children: [
                    Expanded(
                      flex: 34,
                      child: Column(
                        children: [
                          Expanded(
                              flex: 2, child: Container(),
                              ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(dataList[index]["lastName"],
                                    style: kPlayerCardTextTS),
                                Text(dataList[index]["firstName"],
                                    style: kPlayerCardTextTS),
                                Text(
                                    DateFormat('dd.MM.yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            dataList[index]["birthday"])),
                                    style:
                                        kPlayerCardTextTS), //dataList[index]["birthday"]
                                Text(teamsTitleList[selectedTeam]['title'],
                                style: kPlayerCardTextTS,),
                                Text(
                                    DateFormat('dd.MM.yyyy').format(DateTime(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            dataList[index]["birthday"]).year + 17, DateTime.fromMillisecondsSinceEpoch(
                                        dataList[index]["birthday"]).month, DateTime.fromMillisecondsSinceEpoch(
                                        dataList[index]["birthday"]).day - 1)),
                                    style:
                                    kPlayerCardTextTS),
                                SizedBox(height: 5,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 23,
                      child: Column(
                        children: [
                          Expanded(
                              flex: 1, child: Container()),
                          Expanded(
                            flex: 30,
                            child: Container(
                              width: 260,
                              height: 300,
                              child: FutureBuilder(
                                future: downloadURL(dataList[index]["photoURL"]),
                                builder: (context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasError) {
                                    return const Icon(
                                      Icons.person,
                                      color: kAmahoroColorMaterial,
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black, width: 5),
                                          image: DecorationImage(
                                            image:
                                                Image.network(snapshot.data!).image,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        width: 180,
                                        height: 240,
                                      ),
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
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                  ],
                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BasicWidgets.buildTitle('Player Cards'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: IconButton(
                      color: kAmahoroColorMaterial,
                      icon: const Icon(Icons.save_alt),
                      onPressed: () async {
                        await createPDF();
                      },
                    ),
                  ),
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
                        ? const Text('No Player found')
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

  savePDF() async {
    Uint8List pdfInBytes = await pdf.save();
    final blob = html.Blob([pdfInBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
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
    //capturePlayerCards macht die ganzen widgets und speichert sie in playerCardImages
    await capturePlayerCards().then(
      (capturedImage) {
        for(var i = 0; i < playerCardImages.length/10.ceil(); i++){
          List<Uint8List> tenImages = [];
          for(var k = 0; k <10; k++){
            if (playerCardImages.length > k+10*i) {
              tenImages.add(playerCardImages[k+10*i]);
            }
          }
          //10 persos passen auf eine seite
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (context) {
                return pw.Column(
                  children: buildRows(tenImages),
                );
              },
            ),
          );
        }
      },
    ).then((value) => savePDF());
  }

  List<pw.Row> buildRows(List<Uint8List> tenImages) {
    List<pw.Row> playercardRows = [];
    List<Uint8List> playerCardtemp = [];
    // über die playerCardImages wird iteriert
    for (var playerCardImage in tenImages) {
      // der temp liste wird ein playercard geaddet
      playerCardtemp.add(playerCardImage);
      // player card temp macht zwei spalten
      if (playerCardtemp.length > 1) {
        playercardRows.add(
          pw.Row(
            children: [
              for (var playercardimage in playerCardtemp)
                pw.Center(
                  child: pw.Container(
                    height: 300,
                    width: 500,
                    child: pw.Image(
                      pw.MemoryImage(playercardimage),
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
        );
        playerCardtemp.clear();
      }
    }
    if (playerCardtemp.isNotEmpty) {
      playercardRows.add(
        pw.Row(
          children: [
            for (var playercardimage in playerCardtemp)
              pw.Center(
                child: pw.Container(
                  height: 300,
                  width: 500,
                  child: pw.Image(
                    pw.MemoryImage(playercardimage),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      );
      playerCardtemp.clear();
    }
    return playercardRows;
  }
}
