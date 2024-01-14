import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  String id;
  String name;

  Team({required this.id, required this.name});
  factory Team.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Team(
      id: snapshot.id,
      name: data['title'] ?? 'Unbekanntes Team',
    );
  }
}
