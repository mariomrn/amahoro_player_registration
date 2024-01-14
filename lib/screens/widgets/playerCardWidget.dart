import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlayerCardWidget extends StatelessWidget {
  /*final String leagueDocID;
  final String seasonDocID;
  final String teamDocID;
  final String playerDocID;*/
  final Map<String, dynamic> playerData; // Spielerdaten
  final String teamName;

  const PlayerCardWidget({
    Key? key,
    /* required this.leagueDocID,
    required this.seasonDocID,
    required this.teamDocID,
    required this.playerDocID,*/
    required this.playerData,
    required this.teamName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.585, // Verhältnis für die Karte
            child: LayoutBuilder(builder: (context, constraints) {
              // Skalierungsfaktoren basierend auf den Dimensionen des AspectRatio-Containers
              double widthScale = constraints.maxWidth / 350;
              //double heightScale = constraints.maxHeight / 220;
*/
    return SafeArea(
        child: Center(
            child: AspectRatio(
                aspectRatio: 1.585, // Verhältnis für die Karte
                child: LayoutBuilder(builder: (context, constraints) {
                  // Skalierungsfaktoren basierend auf den Dimensionen des AspectRatio-Containers
                  double widthScale = constraints.maxWidth / 350;
                  //double heightScale = constraints.maxHeight / 220;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD3E7ED),
                          Color(0xFFD3E7ED),
                          Color(0xFFF7F5D5),
                          Color(0xFFF7F5D5),
                          Color(0xFFF7F5D5),
                          Color(0xFFDDE9D3),
                          Color(0xFFDDE9D3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [
                          0.33,
                          0.330001,
                          0.330002,
                          0.66,
                          0.660001,
                          0.660002,
                          1
                        ],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 3, // 3 parts for header and text fields
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              HeaderWithLogo(scale: widthScale),
                              SizedBox(height: 4.0 * widthScale),
                              CardField(
                                  label: 'FAMILY NAME',
                                  data: playerData['lastName'] ?? '',
                                  scale:
                                      widthScale), //hier kommt inhalt von firebase
                              CardField(
                                  label: 'FIRST NAME',
                                  data: playerData['firstName'] ?? '',
                                  scale:
                                      widthScale), //hier kommt inhalt von firebase
                              CardField(
                                  label: 'DATE OF BIRTH',
                                  data: DateFormat('dd.MM.yyyy')
                                      .format(playerData['birthday'] ?? ''),
                                  scale:
                                      widthScale), //hier kommt inhalt von firebase
                              CardField(
                                  label: 'TEAM',
                                  data: teamName, //playerData['teamName'],
                                  scale:
                                      widthScale), //hier kommt inhalt von firebase
                              CardField(
                                  label: 'VALID UNTIL',
                                  data: DateFormat('dd.MM.yyyy').format(
                                      DateTime(
                                          playerData['birthday'].year + 17,
                                          playerData['birthday'].month,
                                          playerData['birthday'].day - 1)),
                                  scale:
                                      widthScale), //hier kommt inhalt von firebase
                              SizedBox(height: 4.0 * widthScale),
                            ],
                          ),
                        ),
                        PhotoContainer(
                          photoUrl: playerData['photoURL'] ?? '', // Foto-URL
                          scale: widthScale,
                        ),
                        // Container(
                        //   margin: EdgeInsets.all(17.0 * widthScale),
                        //   width: 140 * widthScale,
                        //   //height: 190 * heightScale,
                        //   // Adjust the width for the photo container as needed
                        //   decoration: BoxDecoration(
                        //     color: Colors
                        //         .white, // White background color for the photo container
                        //     border: Border.all(
                        //       color: Colors.black, // Color for the border
                        //       width: 2.0, // Width of the border
                        //     ),
                        //   ),
                        //   child: Center(child: Text('PHOTO')),
                        // ),
                      ],
                    ),
                  );
                  /*return AspectRatio(
      aspectRatio: 1.585,
      child: FutureBuilder<Map<String, dynamic>>(
        future:
            fetchPlayerData(leagueDocID, seasonDocID, teamDocID, playerDocID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Fehler beim Laden der Daten');
          } else {
            var playerData = snapshot.data!;
            double widthScale = MediaQuery.of(context).size.width / 350;

            return buildPlayerCard(playerData, widthScale);
          }
        },
      ),
    );*/
                }))));
  }

  /*
  @override
  Widget buildPlayerCard(Map<String, dynamic> playerData, double widthScale) {
    /*return Scaffold(
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.585, // Verhältnis für die Karte
            child: LayoutBuilder(builder: (context, constraints) {
              // Skalierungsfaktoren basierend auf den Dimensionen des AspectRatio-Containers
              double widthScale = constraints.maxWidth / 350;
              //double heightScale = constraints.maxHeight / 220;
*/
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD3E7ED),
            Color(0xFFD3E7ED),
            Color(0xFFF7F5D5),
            Color(0xFFF7F5D5),
            Color(0xFFF7F5D5),
            Color(0xFFDDE9D3),
            Color(0xFFDDE9D3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.33, 0.330001, 0.330002, 0.66, 0.660001, 0.660002, 1],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3, // 3 parts for header and text fields
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                HeaderWithLogo(scale: widthScale),
                SizedBox(height: 8.0),
                CardField(
                    label: 'FAMILY NAME',
                    data: playerData['lastName'] ?? '',
                    scale: widthScale), //hier kommt inhalt von firebase
                CardField(
                    label: 'FIRST NAME',
                    data: playerData['firstName'] ?? '',
                    scale: widthScale), //hier kommt inhalt von firebase
                CardField(
                    label: 'DATE OF BIRTH',
                    data: playerData['birthday'] ?? '',
                    scale: widthScale), //hier kommt inhalt von firebase
                CardField(
                    label: 'TEAM',
                    data: teamName, //playerData['teamName'],
                    scale: widthScale), //hier kommt inhalt von firebase
                CardField(
                    label: 'VALID UNTIL',
                    data: DateFormat('dd.MM.yyyy').format(DateTime(
                        playerData['birthday'].year + 17,
                        playerData['birthday'].month,
                        playerData['birthday'].day)),
                    scale: widthScale), //hier kommt inhalt von firebase
              ],
            ),
          ),

          PhotoContainer(
            photoUrl: playerData['photoURL'] ?? '', // Foto-URL
            scale: widthScale,
          ),
          // Container(
          //   margin: EdgeInsets.all(17.0 * widthScale),
          //   width: 140 * widthScale,
          //   //height: 190 * heightScale,
          //   // Adjust the width for the photo container as needed
          //   decoration: BoxDecoration(
          //     color: Colors
          //         .white, // White background color for the photo container
          //     border: Border.all(
          //       color: Colors.black, // Color for the border
          //       width: 2.0, // Width of the border
          //     ),
          //   ),
          //   child: Center(child: Text('PHOTO')),
          // ),
        ],
      ),
    );
/*            }),
          ),
        ),
      ),
    );*/
  }
*/
}

class HeaderWithLogo extends StatelessWidget {
  final double scale;

  HeaderWithLogo({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 8.0 * scale, top: 8.0 * scale, bottom: 8.0 * scale),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Align to the start of the row
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: <Widget>[
          CircleAvatar(
            backgroundImage: const AssetImage(
                '/images/Kimisagara-YL-Logo.png'), //Variabel machen je nach liga
// Stellen Sie die Radiusgröße entsprechend ein, um das Bild klar zu halten
            radius: 25.0 * scale,
          ),
          SizedBox(
              width: 8.0 * scale), // Add space between the logo and the text
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center vertically inside the column
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align text to the start (left)
            children: <Widget>[
              Text(
                'PLAYER CARD',
                style: TextStyle(
                  color: Color(0xFF3590AD), // New text color
                  fontFamily: 'LilitaOne',
                  fontSize: 18 * scale, // Adjust the font size
                ),
              ),
              Text(
                'KIMISAGARA YOUTH LEAGUE', //Variable machen je nach Liga und to Uppercase
                style: TextStyle(
                  color: Color(0xFF3590AD), // New text color
                  fontFamily: 'LilitaOne',
                  fontSize: 8 * scale, // Adjust the font size
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardField extends StatelessWidget {
  final String label;
  final double scale;
  final String data;

  const CardField(
      {Key? key, required this.label, required this.data, required this.scale})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 8.0 * scale, vertical: 3.0 * scale),
        /*child: TextFormField(
          // nicht unbedingt Textfeld?
          decoration: InputDecoration(
            labelText: label,
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale),
            labelStyle: TextStyle(
                fontSize: 10.0 * scale), // Skalierung der Schriftgröße
          ),
          style: TextStyle(fontSize: 13.0 * scale),
        ),*/
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize:
                    7.0 * scale, // Skalierung der Schriftgröße für das Label
                fontWeight: FontWeight.w100,
              ),
            ),
            Expanded(
              child: Text(
                data,
                style: TextStyle(
                  fontSize:
                      13.0 * scale, // Skalierung der Schriftgröße für die Daten
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.zero,
              height: 1.0,
              color: Colors.black, // Farbe der Underline
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoContainer extends StatelessWidget {
  final String photoUrl; // URL des Fotos
  final double scale;

  const PhotoContainer({
    Key? key,
    required this.photoUrl,
    required this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0 * scale),
      width: 140 * scale,
      decoration: BoxDecoration(
        color: Colors.white, // Weißer Hintergrund für den Foto-Container
        border: Border.all(
          color: Colors.black, // Farbe des Rahmens
          width: 2.0, // Breite des Rahmens
        ),
      ),
      child: /*FutureBuilder(
          future: FirebaseStorage.instance.ref(photoUrl).getDownloadURL(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Zeigt einen Ladeindikator an
            } else if (snapshot.hasError) {
              return Text('Fehler beim Laden des Bildes'); // Fehlerbehandlung
            } else {
              return Image.network(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            }
          },
        )*/
          Image.network(
        photoUrl,
        fit: BoxFit.cover, // Stellt sicher, dass das Bild den Container füllt
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('Foto nicht verfügbar'));
        },
      ),
    );
  }
}

/*
Future<Map<String, dynamic>> fetchPlayerData(String leagueDocID,
    String seasonDocID, String teamDocID, String playerId) async {
  // Pfad zur Firestore-Spieler-Dokument
  var playerDocument = FirebaseFirestore.instance
      .collection("league")
      .doc(leagueDocID)
      .collection('season')
      .doc(seasonDocID)
      .collection('teams')
      .doc(teamDocID)
      .collection('players')
      .doc(playerId);

  // Pfad zum Team-Dokument
  var teamDocument = FirebaseFirestore.instance
      .collection("league")
      .doc(leagueDocID)
      .collection('season')
      .doc(seasonDocID)
      .collection('teams')
      .doc(teamDocID);

  var teamSnapshot = await teamDocument.get();
  var teamData = teamSnapshot.data() ?? {};

  var playerSnapshot = await playerDocument.get();
  var playerData = playerSnapshot.data() ?? {};
  // Kombinieren Sie die Spielerdaten mit dem Teamnamen
  return {
    ...playerData,
    'teamName': teamData['title'] ??
        'Unbekanntes Team', // Fügen Sie den Teamnamen hinzu
  };
}
*/
