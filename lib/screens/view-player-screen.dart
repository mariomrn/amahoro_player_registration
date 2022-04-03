import 'package:amahoro_player_registration/models/player.dart';
import 'package:flutter/material.dart';

class ViewPlayerScreen extends StatefulWidget {
  const ViewPlayerScreen({Key? key}) : super(key: key);

  @override
  _ViewPlayerScreenState createState() => _ViewPlayerScreenState();
}

class _ViewPlayerScreenState extends State<ViewPlayerScreen> {
  List<Player> playerList = [
    Player(
      firstName: 'Onika',
      lastName: 'Käse',
      birthday: DateTime(1999),
      playerID: 123124,
    ),
    Player(
      firstName: 'Tay',
      lastName: 'Lor',
      birthday: DateTime(2000),
      playerID: 20137,
    ),
  ];

  List<Widget> _buildList() {
    List<ListTile> listTiles = [];
    for (Player player in playerList) {
      listTiles.add(ListTile(
        title: Text(player.firstName + " " + player.lastName),
        subtitle: Text(player.birthday.toString()),
      ));
    }
    return listTiles;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: _buildList(),
      ),
    );
  }
}
