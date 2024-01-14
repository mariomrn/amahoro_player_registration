import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  Player(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.birthday,
      required this.photoURL});

  String firstName;
  String lastName;
  DateTime birthday;
  String id;
  // String team;
  // String validUntil;
  String photoURL;

  factory Player.fromSnapshot(DocumentSnapshot snapshot, String photoUrl) {
    var data = snapshot.data() as Map<String, dynamic>;
    DateTime birthday =
        DateTime.fromMillisecondsSinceEpoch(data['birthday'] ?? '');
    return Player(
      id: snapshot.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      birthday: birthday,
      photoURL: photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Konvertieren Sie alle Felder in ein Map-Format
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday,
      'photoURL': photoURL
    };
  }
}
