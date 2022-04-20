import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> downloadURL(String imageName) async {
    String downloadURL =
        await storage.ref('players/' + imageName).getDownloadURL();
    return downloadURL;
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
          subtitle: Text(DateFormat('dd.MM.yyyy').format(
              DateTime.fromMillisecondsSinceEpoch(
                  dataList[index]["birthday"]))),
          trailing: Text(dataList[index]["positions"]),
        );
      });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // FutureBuilder(
            //   future: getData(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasError) {
            //       return const Text(
            //         "Something went wrong",
            //       );
            //     }
            //     if (snapshot.connectionState == ConnectionState.done) {
            //       return buildItems(playerList);
            //     }
            //     return const Center(child: CircularProgressIndicator());
            //   },
            // ),
            ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.custom,
                    allowedExtensions: ['png', 'jpg'],
                  );
                  if (result == null) {
                    print('fehlerrrrrrrrr');
                    return;
                  }
                  if (result != null && result.files.isNotEmpty) {
                    final fileBytes = result.files.first.bytes;
                    final fileName = result.files.first.name;
                    // upload file
                    await storage.ref('players/$fileName').putData(fileBytes!);
                  }
                },
                child: Text('Upload a file')),
            FutureBuilder(
              future: downloadURL('phipsiii.png'),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Something went wrong",
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    width: 300,
                    height: 300,
                    child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}
