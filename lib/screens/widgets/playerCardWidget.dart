import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

class PlayerCardWidget extends StatefulWidget {
  final Map<String, dynamic> playerData; // Spielerdaten
  final String teamName;

  const PlayerCardWidget({
    Key? key,
    required this.playerData,
    required this.teamName,
  }) : super(key: key);

  //final GlobalKey<_PlayerCardWidgetState> repaintBoundaryKey = GlobalKey();

  /*Future<Uint8List?> takeScreenshot() async {
    return repaintBoundaryKey.currentState?.takeScreenshot();
  }*/

  @override
  _PlayerCardWidgetState createState() => _PlayerCardWidgetState();
}

class _PlayerCardWidgetState extends State<PlayerCardWidget> {
  /*Future<Uint8List?> takeScreenshot() async {
    RenderRepaintBoundary? boundary = widget.repaintBoundaryKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    }
    return null;
  }*/

  /* @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Uint8List? imageBytes = await takeScreenshot();
      if (imageBytes != null) {
        // Verarbeiten Sie den Screenshot wie erforderlich
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return /*RepaintBoundary(
      key: widget.repaintBoundaryKey,
      child: */
        SafeArea(
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.585, // Verhältnis für die Karte
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Skalierungsfaktoren basierend auf den Dimensionen des AspectRatio-Containers
              double widthScale = constraints.maxWidth / 350;
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
                              data: widget.playerData['lastName'] ?? '',
                              scale:
                                  widthScale), //hier kommt inhalt von firebase
                          CardField(
                              label: 'FIRST NAME',
                              data: widget.playerData['firstName'] ?? '',
                              scale:
                                  widthScale), //hier kommt inhalt von firebase
                          CardField(
                              label: 'DATE OF BIRTH',
                              data: DateFormat('dd.MM.yyyy')
                                  .format(widget.playerData['birthday'] ?? ''),
                              scale:
                                  widthScale), //hier kommt inhalt von firebase
                          CardField(
                              label: 'TEAM',
                              data: widget.teamName, //playerData['teamName'],
                              scale:
                                  widthScale), //hier kommt inhalt von firebase
                          CardField(
                              label: 'VALID UNTIL',
                              data: DateFormat('dd.MM.yyyy').format(DateTime(
                                  widget.playerData['birthday'].year + 17,
                                  widget.playerData['birthday'].month,
                                  widget.playerData['birthday'].day - 1)),
                              scale:
                                  widthScale), //hier kommt inhalt von firebase
                          SizedBox(height: 4.0 * widthScale),
                        ],
                      ),
                    ),
                    PhotoContainer(
                      photoUrl: widget.playerData['photoURL'] ?? '', // Foto-URL
                      scale: widthScale,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      //),
    );
  }
}

class HeaderWithLogo extends StatelessWidget {
  final double scale;

  const HeaderWithLogo({Key? key, required this.scale}) : super(key: key);

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
      child: Image.network(
        photoUrl,
        fit: BoxFit.cover, // Stellt sicher, dass das Bild den Container füllt
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('Foto nicht verfügbar'));
        },
      ),
    );
  }
}
