import 'dart:typed_data';

import 'package:amahoro_player_registration/screens/widgets/playerCardWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
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
                //createPdfWithPlayerCards(playerCards);
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
                padding: const EdgeInsets.only(
                    bottom: 10.0), // Fügt Abstand unter jeder Karte hinzu
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
        // Konvertieren Sie das Player-Objekt in eine Map
        Map<String, dynamic> playerMap = player.toMap();
        ScreenshotController screenshotController = ScreenshotController();
        screenshotControllerList.add(screenshotController);
        return PlayerCardWidget(
          playerData: playerMap,
          teamName: teamName,
        );
      }).toList();
    });
  }

  /*void exportPlayerCardsAsPDF(List<PlayerCardWidget> playerCardsData) async {
    final pdf = pw.Document();
    final cardWidth = 242.0; // Breite in Punkten
    final cardHeight = 153.0; // Höhe in Punkten
    final pageMargin = 10.0; // Seitenrand in Punkten
    final pageFormat = PdfPageFormat.a4; // A4-Format

    // Berechnen, wie viele Karten pro Zeile/Spalte passen
    int cardsPerRow = (pageFormat.width / (cardWidth + pageMargin)).floor();
    int cardsPerColumn =
        (pageFormat.height / (cardHeight + pageMargin)).floor();

    // Erstellen Sie PDF-Seiten und fügen Sie Karten hinzu
    for (var i = 0;
        i < playerCardsData.length;
        i += cardsPerRow * cardsPerColumn) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.GridView(
              crossAxisCount: cardsPerRow,
              childAspectRatio: cardWidth / cardHeight,
              children: playerCardsData
                  .skip(i)
                  .take(cardsPerRow * cardsPerColumn)
                  .map((cardData) {
                // Konvertieren Sie das Player-Objekt in eine Map
                Map<String, dynamic> playerMap = cardData.toMap();
                return PlayerCardWidget(
                  playerData: playerMap,
                  teamName: selectedTeam.name,
                ); // Ersetzen Sie dies durch Ihre Funktion zur Erstellung der PlayerCard
              }).toList(),
            );
          },
        ),
      );
    }*/
  /*Future<void> createScreenshots(List<PlayerCardWidget> playerCards) async {
    for (var card in playerCards) {
      Uint8List? imageBytes = await card.takeScreenshot();
      if (imageBytes != null) {
        // Verarbeiten Sie das Bild, z.B. durch Hinzufügen zu einem PDF oder Speichern
      }
    }
  }
*/
  /*Future<void> createPdfWithPlayerCards(
      List<PlayerCardWidget> playerCards) async {
    final pdf = pw.Document();

    for (var card in playerCards) {
      Uint8List? imageBytes = await card.takeScreenshot();
      if (imageBytes != null) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(pw.MemoryImage(imageBytes)),
              );
            },
          ),
        );
      } else {
        print("Screenshot konnte nicht erstellt werden.");
      }
    }

    // Speichern der PDF
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/player_cards/$selectedTeam.pdf');
      await file.writeAsBytes(await pdf.save());
      print("PDF gespeichert in ${file.path}");
    } catch (e) {
      print("Fehler beim Speichern der PDF: $e");
    }
  }*/

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
    print('Wir sind hier: length ' + playerCardImages.length.toString());
    print('Wir sind hier: screenshotlength ' +
        screenshotControllerList.length.toString());

    return playerCardImages;
  }

  createPDF() async {
    //final pdf = pw.Document();
    const cardWidth = 242.0; // Breite in Punkten
    const cardHeight = 153.0; // Höhe in Punkten
    const pageMargin = 10.0; // Seitenrand in Punkten
    const pageFormat = PdfPageFormat.a4; // A4-Format

    // Berechnen, wie viele Karten pro Zeile/Spalte passen
    int cardsPerRow = (pageFormat.width / (cardWidth + pageMargin)).floor();
    int cardsPerColumn =
        (pageFormat.height / (cardHeight + pageMargin)).floor();
    pdf = pw.Document();
    //capturePlayerCards macht die ganzen widgets und speichert sie in playerCardImages
    await capturePlayerCards().then(
      (capturedImage) {
        /*for (var i = 0; i < playerCardImages.length / 5.ceil(); i++) {
          List<Uint8List> tenImages = [];
          for (var k = 0; k < 5; k++) {
            if (playerCardImages.length > k + 5 * i) {
              tenImages.add(playerCardImages[k + 5 * i]);
            }
          }
          //new
          //10 persos passen auf eine seite
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (context) {
                return pw.Column(
                  children: buildRows(tenImages),
                );
              },
            ),*/

        // Erstellen Sie PDF-Seiten und fügen Sie Karten hinzu
        for (var i = 0;
            i < playerCardImages.length;
            i += cardsPerRow * cardsPerColumn) {
          pdf.addPage(pw.Page(
            pageFormat: pageFormat,
            build: (pw.Context context) {
              return pw.GridView(
                crossAxisCount: cardsPerRow,
                childAspectRatio: cardWidth / cardHeight,
                children: playerCardImages
                    .skip(i)
                    .take(cardsPerRow * cardsPerColumn)
                    .map((imageData) => pw.Image(pw.MemoryImage(imageData)))
                    .toList(),
              );
            },
          ));
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
      if (true) {
        playercardRows.add(
          pw.Row(
            children: [
              for (var playercardimage in playerCardtemp)
                pw.Center(
                  child: pw.Container(
                    width: 242,
                    height: 153,
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
    if (false) {
      playercardRows.add(
        pw.Row(
          children: [
            for (var playercardimage in playerCardtemp)
              pw.Center(
                child: pw.Container(
                  width: 400,
                  height: 400,
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
