import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:amahoro_player_registration/screens/widgets/basicWidgets.dart';
import 'package:amahoro_player_registration/theme/colors.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class SecondRoute extends StatelessWidget {
  Map<String, dynamic> playerInfo;
  String currentPlayerIndex;
  String selectedTeamName;
  String selectedLeagueName;
  String selectedLeagueDoc;
  String selectedSeasonDoc;
  String selectedTeamsDoc;
  List teamsTitleList = [];
  List teamsDocumentList = [];

  SecondRoute(
      this.playerInfo,
      this.currentPlayerIndex,
      this.selectedLeagueName,
      this.selectedTeamName,
      this.selectedLeagueDoc,
      this.selectedSeasonDoc,
      this.selectedTeamsDoc,
      this.teamsTitleList,
      this.teamsDocumentList,
      {Key? key})
      : super(key: key);

  Future<String> downloadURL(String storageRef) async {
    String downloadURL = await storage.ref(storageRef).getDownloadURL();
    return downloadURL;
  }

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    Future<void> savePlayer(
        String docID1,
        String docID2,
        String docID3,
        String firstName,
        String lastName,
        int birthday,
        String storageRef) async {
      CollectionReference leagueCollectionRef =
          FirebaseFirestore.instance.collection("league");
      return leagueCollectionRef
          .doc(docID1)
          .collection('season')
          .doc(docID2)
          .collection('teams')
          .doc(docID3)
          .collection('players')
          .add({
        'firstName': firstName,
        'lastName': lastName,
        'birthday': birthday,
        'photoURL': storageRef,
      }).then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Swap success')));
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Fail')));
      });
    }

    Future<void> deletePlayer(
        String docID1, String docID2, String docID3) async {
      CollectionReference leagueCollectionRef =
          FirebaseFirestore.instance.collection("league");
      // FirebaseFirestore.instance.runTransaction((transaction) async =>
      // await transaction.delete(leagueCollectionRef
      //     .doc(docID1)
      //     .collection('season')
      //     .doc(docID2)
      //     .collection('teams')
      //     .doc(docID3)
      //     .collection('players').doc(currentPlayerIndex).toString()));
      print(leagueCollectionRef
          .doc(docID1)
          .collection('season')
          .doc(docID2)
          .collection('teams')
          .doc(docID3)
          .collection('players')
          .doc(currentPlayerIndex)
          .toString());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Player Info"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Center(
          child: Column(
            children: [
              FutureBuilder(
                future: downloadURL(playerInfo["photoURL"]),
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasError) {
                    return const Icon(
                      Icons.person,
                      color: kAmahoroColorMaterial,
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Center(
                              child: CircleAvatar(
                                radius: 110,
                                backgroundColor: kAmahoroColorMaterial,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      Image.network(snapshot.data!).image,
                                  radius: 105,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BasicWidgets.buildTitle('League'),
                        Text(selectedLeagueName),
                        const SizedBox(height: 10),
                        ListTile(
                          onTap: () {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text('Add to another Team'),
                                      const SizedBox(height: 15),
                                      Column(
                                        children: List<Widget>.generate(
                                          teamsTitleList.length,
                                          (int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: TextButton(
                                                  onPressed: () {
                                                    savePlayer(
                                                        selectedLeagueDoc,
                                                        selectedSeasonDoc,
                                                        teamsDocumentList[
                                                            index],
                                                        playerInfo["firstName"],
                                                        playerInfo["lastName"],
                                                        playerInfo["birthday"],
                                                        playerInfo["photoURL"]);
                                                    //TODO DELETE THIS PLAYER FROM CURRENT TEAM
                                                    Navigator.pop(context);
                                                  },
                                                  style: TextButton.styleFrom(
                                                    primary: teamsTitleList[
                                                                    index]
                                                                ['title'] ==
                                                            selectedTeamName
                                                        ? kAmahoroColor
                                                        : Colors
                                                            .grey, // Text Color
                                                  ),
                                                  child: Text(
                                                      teamsTitleList[index]
                                                          ['title'])),
                                            );
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          title: Text(selectedTeamName),
                          subtitle: Text('Team'),
                        ),
                        const SizedBox(height: 10),
                        BasicWidgets.buildTitle('First Name'),
                        Text(playerInfo["firstName"]),
                        const SizedBox(height: 10),
                        BasicWidgets.buildTitle('Last Name'),
                        Text(playerInfo["lastName"]),
                        const SizedBox(height: 10),
                        BasicWidgets.buildTitle('Birthday'),
                        Text(DateFormat('dd.MM.yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                playerInfo["birthday"]))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
