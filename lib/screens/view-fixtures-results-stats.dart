import 'package:amahoro_player_registration/screens/view-match-day-screen.dart';
import 'package:amahoro_player_registration/screens/results-table.dart';
import 'package:flutter/material.dart';

class ViewFixturesResultsStats extends StatefulWidget {
  const ViewFixturesResultsStats({Key? key}) : super(key: key);

  @override
  State<ViewFixturesResultsStats> createState() =>
      _ViewFixturesResultsStatsState();
}

class _ViewFixturesResultsStatsState extends State<ViewFixturesResultsStats> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Anzahl der Tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Meine Tabs'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sports_soccer), text: 'Match Day'),
              Tab(icon: Icon(Icons.table_chart), text: 'Results Table'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ViewMatchDayScreen(), // Ihr Widget für den Match Day
            ResultsTableView(), // Ihr Widget für die Ergebnistabelle
            StatsView(), // Ihr Widget für Statistiken
          ],
        ),
      ),
    );
  }
}

class StatsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implementieren Sie Ihre StatsView
    return Center(child: Text('Stats View'));
  }
}
