import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Team-Klasse
class Team {
  String name;
  int wins;
  int draws;
  int losses;
  int goalsFor;
  int goalsAgainst;

  int get points => wins * 3 + draws;
  int get goalDifference => goalsFor - goalsAgainst;

  Team({
    required this.name,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  factory Team.fromFirestore(Map<String, dynamic> firestore) {
    return Team(
      name: firestore['title'],
      wins: firestore['wins'],
      draws: firestore['draws'],
      losses: firestore['losses'],
      goalsFor: firestore['goals scored'],
      goalsAgainst: firestore['goals received'],
    );
  }
}

// ResultsTableView-Klasse
class ResultsTableView extends StatefulWidget {
  const ResultsTableView({Key? key}) : super(key: key);

  @override
  _ResultsTableViewState createState() => _ResultsTableViewState();
}

class _ResultsTableViewState extends State<ResultsTableView> {
  String leagueDocId = 'bCQQ0U7Ir8zSZFDU6Kv6';
  String seasonDocId = 'eRmGgNQrCYmO2f9iXzeb';
  Future<List<Team>> fetchTeams() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('league')
        .doc(leagueDocId)
        .collection('season')
        .doc(seasonDocId)
        .collection('teams')
        .get();

    return snapshot.docs
        .map((doc) => Team.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Team>>(
      future: fetchTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return buildTable(snapshot.data!);
        } else {
          return Text("Keine Daten gefunden");
        }
      },
    );
  }

  Widget buildTable(List<Team> teams) {
    // Sortierung und Darstellung der Teams
    teams.sort((a, b) {
      if (b.points != a.points) return b.points.compareTo(a.points);
      if (b.goalDifference != a.goalDifference)
        return b.goalDifference.compareTo(a.goalDifference);
      return b.goalsFor.compareTo(a.goalsFor);
    });

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Team')),
          DataColumn(label: Text('Spiele')),
          DataColumn(label: Text('Siege')),
          DataColumn(label: Text('Unentschieden')),
          DataColumn(label: Text('Niederlagen')),
          DataColumn(label: Text('Tore')),
          DataColumn(label: Text('Gegentore')),
          DataColumn(label: Text('Tordifferenz')),
          DataColumn(label: Text('Punkte')),
        ],
        rows: teams
            .map((team) => DataRow(
                  cells: [
                    DataCell(Text(team.name)),
                    DataCell(Text(
                        (team.wins + team.draws + team.losses).toString())),
                    DataCell(Text(team.wins.toString())),
                    DataCell(Text(team.draws.toString())),
                    DataCell(Text(team.losses.toString())),
                    DataCell(Text(team.goalsFor.toString())),
                    DataCell(Text(team.goalsAgainst.toString())),
                    DataCell(Text(team.goalDifference.toString())),
                    DataCell(Text(team.points.toString())),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
