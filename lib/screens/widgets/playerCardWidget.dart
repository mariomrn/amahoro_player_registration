import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class PlayerCardWidget extends StatelessWidget {
  final Map<String, dynamic> playerData;
  final String teamName;
  final GlobalKey repaintBoundaryKey;

  PlayerCardWidget({
    Key? key,
    required this.playerData,
    required this.teamName,
    required this.repaintBoundaryKey,
  }) : super(key: key);

  Future<Uint8List?> capture() async {
    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing widget: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.585,
            child: LayoutBuilder(
              builder: (context, constraints) {
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
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            HeaderWithLogo(scale: widthScale),
                            SizedBox(height: 4.0 * widthScale),
                            CardField(
                                label: 'FAMILY NAME',
                                data: playerData['lastName'] ?? '',
                                scale: widthScale),
                            CardField(
                                label: 'FIRST NAME',
                                data: playerData['firstName'] ?? '',
                                scale: widthScale),
                            CardField(
                                label: 'DATE OF BIRTH',
                                data: DateFormat('dd.MM.yyyy')
                                    .format(playerData['birthday'] ?? ''),
                                scale: widthScale),
                            CardField(
                                label: 'TEAM',
                                data: teamName,
                                scale: widthScale),
                            CardField(
                                label: 'VALID UNTIL',
                                data: DateFormat('dd.MM.yyyy').format(DateTime(
                                    playerData['birthday'].year + 17,
                                    playerData['birthday'].month,
                                    playerData['birthday'].day - 1)),
                                scale: widthScale),
                            SizedBox(height: 4.0 * widthScale),
                          ],
                        ),
                      ),
                      PhotoContainer(
                        photoUrl: playerData['photoURL'] ?? '',
                        scale: widthScale,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: const AssetImage('/images/Kimisagara-YL-Logo.png'),
            radius: 25.0 * scale,
          ),
          SizedBox(width: 8.0 * scale),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'PLAYER CARD',
                style: TextStyle(
                  color: Color(0xFF3590AD),
                  fontFamily: 'LilitaOne',
                  fontSize: 18 * scale,
                ),
              ),
              Text(
                'KIMISAGARA YOUTH LEAGUE',
                style: TextStyle(
                  color: Color(0xFF3590AD),
                  fontFamily: 'LilitaOne',
                  fontSize: 8 * scale,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 7.0 * scale,
                fontWeight: FontWeight.w100,
              ),
            ),
            Expanded(
              child: Text(
                data,
                style: TextStyle(
                  fontSize: 13.0 * scale,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.zero,
              height: 1.0,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class PhotoContainer extends StatelessWidget {
  final String photoUrl;
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
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
      ),
      child: Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('Foto nicht verfügbar'));
        },
      ),
    );
  }
}
