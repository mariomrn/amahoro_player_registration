import 'dart:async';
import 'dart:typed_data';
import 'package:amahoro_player_registration/screens/widgets/playerCardWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'dart:html' as html;
import '../models/player.dart';
import '../models/team.dart';

class TeamSelectionPage extends StatefulWidget {
  final String leagueDocID;
  final String seasonDocID;

  const TeamSelectionPage({
    Key? key,
    required this.leagueDocID,
    required this.seasonDocID,
  }) : super(key: key);

  @override
  _TeamSelectionPageState createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  String? selectedTeamId;
  Team? selectedTeam;
  List<PlayerCardWidget> playerCards = [];
  List<ScreenshotController> screenshotControllerList = [];
  var pdf = pw.Document();
  List<Uint8List> playerCardImages = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            FutureBuilder<List<Team>>(
              future: fetchTeams(widget.leagueDocID, widget.seasonDocID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Keine Teams gefunden');
                }
                var teams = snapshot.data!;
                return DropdownButton<String>(
                  value: selectedTeamId,
                  onChanged: (newValue) {
                    setState(() {
                      selectedTeamId = newValue;
                      var selectedTeam =
                          teams.firstWhere((team) => team.id == newValue);
                      loadPlayerCards(selectedTeam.id, selectedTeam.name);
                    });
                  },
                  items: teams.map<DropdownMenuItem<String>>((Team team) {
                    return DropdownMenuItem<String>(
                      value: team.id,
                      child: Text(team.name),
                    );
                  }).toList(),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () {
                createPDF();
              },
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            itemCount: playerCards.length,
            itemBuilder: (context, index) {
              Widget playerCard = Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Screenshot(
                    controller: screenshotControllerList[index],
                    child: playerCards[index]),
              );
              return playerCard;
            },
          ),
        ),
      ],
    );
  }

  void loadTeamData(String teamId) async {
    var teamSnapshot = await FirebaseFirestore.instance
        .collection("league")
        .doc(widget.leagueDocID)
        .collection('season')
        .doc(widget.seasonDocID)
        .collection('teams')
        .doc(teamId)
        .get();

    var teamData = teamSnapshot.data() ?? {};
    var teamName = teamData['title'] ?? 'Unbekanntes Team';

    loadPlayerCards(teamId, teamName);
  }

  void loadPlayerCards(String teamId, String teamName) async {
    var players =
        await fetchPlayers(widget.leagueDocID, widget.seasonDocID, teamId);
    setState(() {
      screenshotControllerList.clear();
      playerCards = players.map((player) {
        Map<String, dynamic> playerMap = player.toMap();
        ScreenshotController screenshotController = ScreenshotController();
        screenshotControllerList.add(screenshotController);
        return PlayerCardWidget(
          playerData: playerMap,
          teamName: teamName,
          repaintBoundaryKey: GlobalKey(), // Ensure unique keys
        );
      }).toList();
    });
  }

  savePDF() async {
    Uint8List pdfInBytes = await pdf.save();
    final blob = html.Blob([pdfInBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchorElement = html.AnchorElement(href: url);
    anchorElement.download = 'player_cards.pdf';
    anchorElement.click();
    html.Url.revokeObjectUrl(url); // Clean up the URL object
  }

  Future<void> capturePlayerCardsOffScreen(BuildContext context) async {
    playerCardImages.clear();
    for (var i = 0; i < playerCards.length; i++) {
      Uint8List? capturedImage =
          await renderAndCapture(context, playerCards[i]);
      if (capturedImage != null) {
        playerCardImages.add(capturedImage);
      } else {
        print('Failed to capture screenshot for a player card');
      }
    }
  }

  Future<Uint8List?> renderAndCapture(
      BuildContext context, Widget widget) async {
    final screenshotController = ScreenshotController();
    final completer = Completer<Uint8List?>();

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: Screenshot(
            controller: screenshotController,
            child: widget,
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlayEntry);

    Future.delayed(Duration(milliseconds: 100), () async {
      try {
        Uint8List? image = await screenshotController.capture();
        completer.complete(image);
      } catch (e) {
        completer.completeError(e);
      } finally {
        overlayEntry.remove();
      }
    });

    return completer.future;
  }

  createPDF() async {
    const cardWidth = 243.78; // Breite in Punkten (8.6 cm)
    const cardHeight = 153.07; // Höhe in Punkten (5.4 cm)
    const pageMargin = 5.0; // Seitenrand in Punkten
    const pageFormat = PdfPageFormat.a4; // A4-Format

    int cardsPerRow = (pageFormat.width / (cardWidth + pageMargin)).floor();
    int cardsPerColumn =
        (pageFormat.height / (cardHeight + pageMargin)).floor();

    pdf = pw.Document();

    await capturePlayerCardsOffScreen(
        context); // Ensure all widgets are rendered off-screen

    for (var i = 0;
        i < playerCardImages.length;
        i += cardsPerRow * cardsPerColumn) {
      pdf.addPage(pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.GridView(
            crossAxisCount: cardsPerRow,
            //childAspectRatio: cardWidth / cardHeight,
            children: playerCardImages
                .skip(i)
                .take(cardsPerRow * cardsPerColumn)
                .map((imageData) => pw.Image(
                      pw.MemoryImage(imageData),
                      width: cardWidth + 60,
                      height: cardHeight,
                      fit: pw.BoxFit.fitWidth,
                    )) // Set image size
                .toList(),
          );
        },
      ));
    }

    savePDF();
  }
}

Future<List<Team>> fetchTeams(String leagueDocID, String seasonDocID) async {
  QuerySnapshot teamSnapshot = await FirebaseFirestore.instance
      .collection('league')
      .doc(leagueDocID)
      .collection('season')
      .doc(seasonDocID)
      .collection('teams')
      .get();

  return teamSnapshot.docs.map((doc) => Team.fromSnapshot(doc)).toList();
}

Future<List<Player>> fetchPlayers(
    String leagueDocID, String seasonDocID, String teamDocID) async {
  QuerySnapshot playerSnapshot = await FirebaseFirestore.instance
      .collection('league')
      .doc(leagueDocID)
      .collection('season')
      .doc(seasonDocID)
      .collection('teams')
      .doc(teamDocID)
      .collection('players')
      .get();

  List<Player> players = [];
  for (var doc in playerSnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    String photoUrl =
        await FirebaseStorage.instance.ref(data['photoURL']).getDownloadURL();
    players.add(Player.fromSnapshot(doc, photoUrl));
  }
  return players;
}
