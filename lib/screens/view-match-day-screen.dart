import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import '../theme/textStyles.dart';

class ViewMatchDayScreen extends StatefulWidget {
  const ViewMatchDayScreen({Key? key}) : super(key: key);

  @override
  _ViewMatchDayScreenState createState() => _ViewMatchDayScreenState();
}

class _ViewMatchDayScreenState extends State<ViewMatchDayScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String leagueDocID = 'bCQQ0U7Ir8zSZFDU6Kv6'; // Beispiel: Liga-Dokument-ID
  String seasonDocID = 'eRmGgNQrCYmO2f9iXzeb'; // Beispiel: Season-Dokument-ID
  int selectedMatchday = 1; // Standardmäßig der erste Spieltag

  Future<List<Map<String, dynamic>>> fetchMatchdayFixtures(int matchday) async {
    List<Map<String, dynamic>> fixtures = [];

    try {
      QuerySnapshot matchdaySnapshot = await firestore
          .collection('league')
          .doc(leagueDocID) // Beispiel: Liga-Dokument-ID
          .collection('season')
          .doc(seasonDocID)
          .collection('matchdays')
          .where('title', isEqualTo: 'Match day $matchday')
          .get();

      if (matchdaySnapshot.docs.isNotEmpty) {
        var matchdayDoc = matchdaySnapshot.docs.first;
        QuerySnapshot matchesSnapshot =
            await matchdayDoc.reference.collection('matches').get();

        for (var match in matchesSnapshot.docs) {
          Map<String, dynamic> matchData = match.data() as Map<String, dynamic>;
          fixtures.add(matchData);
        }
      }
    } catch (e) {
      debugPrint("Error fetching matchday fixtures: $e");
    }

    return fixtures;
  }

  Widget buildMatchdayFixtures() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchMatchdayFixtures(selectedMatchday),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Keine Spiele gefunden.');
        }
        List<Map<String, dynamic>> fixtures = snapshot.data!;
        return buildMatchItems(fixtures);
      },
    );
  }

  Widget buildMatchItems(List<Map<String, dynamic>> dataList) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: dataList.length,
      separatorBuilder: (BuildContext context, int index) => Container(
        height: 10,
      ),
      itemBuilder: (BuildContext context, int index) {
        var match = dataList[index];
        return Container(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hier können Sie weitere Designelemente hinzufügen
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${match['home']} ${match['goalshome']} : ${match['goalsaway']} ${match['away']}',
                        style: kNameTS,
                        textAlign: TextAlign.center,
                      ),
                      // Sie können hier weitere Details hinzufügen, z.B. Spielzeit
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fixtures', style: kTitleTextStyle),
        backgroundColor: kAmahoroColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              value: selectedMatchday,
              onChanged: (int? newValue) {
                setState(() {
                  selectedMatchday = newValue!;
                });
              },
              items: List.generate(
                9, // Annahme: 10 Spieltage, passen Sie diese Zahl entsprechend an
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('Match Day ${index + 1}'),
                ),
              ),
            ),
          ),
          Expanded(
            child: buildMatchdayFixtures(),
          ),
        ],
      ),
    );
  }
}
