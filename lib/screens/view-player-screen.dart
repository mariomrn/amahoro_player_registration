import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewPlayerScreen extends StatefulWidget {
  const ViewPlayerScreen({Key? key}) : super(key: key);

  @override
  _ViewPlayerScreenState createState() => _ViewPlayerScreenState();
}

class _ViewPlayerScreenState extends State<ViewPlayerScreen> {
  List playerList = [];
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection("player");

  Future getData() async {
    try {
      await collectionRef.get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          playerList.add(result.data());
        }
      });
      return playerList;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Widget buildItems(dataList) => ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: dataList.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            dataList[index]["firstName"] + ' ' + dataList[index]["lastName"],
          ),
          subtitle: Text(DateFormat('dd.MM.yyyy').format(DateTime.fromMillisecondsSinceEpoch(dataList[index]["birthday"]))),
          trailing: Text(dataList[index]["positions"]),
        );
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                "Something went wrong",
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return buildItems(playerList);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
