import 'package:amahoro_player_registration/screens/widgets/playerCardWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
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

                  //loadTeamData(newValue!); //ich möchte verhindern, dass erneut von firebase geladen wird
                  //loadPlayerCards(newValue!);
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            itemCount: playerCards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 10.0), // Fügt Abstand unter jeder Karte hinzu
                child: playerCards[index],
              );
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
      playerCards = players.map((player) {
        // Konvertieren Sie das Player-Objekt in eine Map
        Map<String, dynamic> playerMap = player.toMap();
        return PlayerCardWidget(
          playerData: playerMap,
          teamName: teamName,
        );
      }).toList();
    });
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

  //return playerSnapshot.docs.map((doc) => Player.fromSnapshot(doc)).toList();
  List<Player> players = [];
  for (var doc in playerSnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    String photoUrl =
        await FirebaseStorage.instance.ref(data['photoURL']).getDownloadURL();
    players.add(Player.fromSnapshot(doc, photoUrl));
  }
  return players;
}
