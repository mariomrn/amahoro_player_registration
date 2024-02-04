import 'dart:typed_data';
import 'package:amahoro_player_registration/screens/widgets/basicWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';
import '../theme/textStyles.dart';
import 'package:flutter/cupertino.dart';

class APS extends StatefulWidget {
  String leagueID;
  String seasonID;
  String teamID;

  APS(this.leagueID, this.seasonID, this.teamID, {Key? key}) : super(key: key);

  @override
  _APSState createState() => _APSState();
}

class _APSState extends State<APS> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference leagueCollectionRef =
  FirebaseFirestore.instance.collection("league");
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool dateGotSelected = false;
  XFile? pickedImage;
  Uint8List? imageBytes;
  late Future _futureGetInitial;
  DateTime date = DateTime(2016, 10, 26);
  DateTime birthdayDate = DateTime.now();

  @override
  void initState() {
    print("widget.leagueID");
    print(widget.leagueID);
    print("widget.seasonID");
    print(widget.seasonID);
    print("widget.teamID");
    print(widget.teamID);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Material(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BasicWidgets.buildTitle('Profile Picture'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: kAmahoroColorMaterial,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: imageBytes != null
                                ? Image.memory(imageBytes!).image
                                : null,
                            radius: 48,
                            child: imageBytes != null
                                ? Container()
                                : const Icon(
                              Icons.person,
                              color: kAmahoroColorMaterial,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'Add Photo',
                        style: kDefaultTextStyle.copyWith(
                            color: kAmahoroColorMaterial.shade700),
                      ),
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        pickedImage = await _picker.pickImage(
                            source: ImageSource.camera,
                            maxHeight: 640,
                            maxWidth: 480,
                            imageQuality: 80);
                        if (pickedImage == null) {
                          return;
                        }
                        if (pickedImage != null) {
                          imageBytes = await pickedImage?.readAsBytes();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
                BasicWidgets.buildTitle('Last Name'),
                TextField(controller: lastNameController, inputFormatters: [
                  UpperCaseTextFormatter(),
                ]),
                BasicWidgets.buildTitle('First Name'),
                TextField(
                  controller: firstNameController,
                ),
                BasicWidgets.buildTitle('Date Of Birth'),
                CupertinoButton(
                  // Display a CupertinoDatePicker in date picker mode.
                  onPressed: () {
                    _showDateDialog(
                      CupertinoDatePicker(
                        dateOrder: DatePickerDateOrder.dmy,
                        initialDateTime: date,
                        mode: CupertinoDatePickerMode.date,
                        use24hFormat: true,
                        // This is called when the user changes the date.
                        onDateTimeChanged: (DateTime newDate) {
                          setState(() => birthdayDate = newDate);
                        },
                      ),
                    );
                    dateGotSelected = true;
                  },
                  child: Text(
                    dateGotSelected
                        ? '${birthdayDate.day}.${birthdayDate.month}.${birthdayDate.year}'
                        : 'no date selected',
                    style: kDefaultTextStyle.copyWith(
                        color: dateGotSelected
                            ? Colors.grey.shade900
                            : Colors.grey.shade500),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30),
                  child: Row(
                    children: [
                      _inProgress
                          ? Container()
                          : Expanded(
                        child: Container(
                          height: 40,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: informationIsComplete()
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              backgroundColor: informationIsComplete()
                                  ? kAmahoroColorMaterial.shade700
                                  : Colors.grey.shade400,
                            ),
                            child: Text(
                              'Submit Player',
                              style: kDefaultTextStyle.copyWith(
                                  color: Colors.white),
                            ),
                            onPressed: informationIsComplete()
                                ? () {
                              addPlayer();
                            }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetValues() {
    firstNameController.clear();
    lastNameController.clear();
    birthdayDate = DateTime.now();
    dateGotSelected = false;
    pickedImage = null;
    imageBytes = null;
  }

  bool informationIsComplete() {
    return dateGotSelected &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        (imageBytes != null) &&
        widget.leagueID.length > 1 &&
        widget.seasonID.length > 1 &&
        widget.teamID.length > 1;
  }

  void _showDateDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  bool _inProgress = false;

  Future<void> addPlayer() async {
    setState(() {
      _inProgress = true;
    });
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    int birthday = birthdayDate.millisecondsSinceEpoch;
    String storageRef =
        'players/${widget.leagueID}/${firstName + lastName + birthday.toString()}';
    await storage.ref(storageRef).putData(imageBytes!);
    return leagueCollectionRef
        .doc(widget.leagueID)
        .collection('season')
        .doc(widget.seasonID)
        .collection('teams')
        .doc(widget.teamID)
        .collection('players')
        .add({
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday,
      'photoURL': storageRef,
    })
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Upload Success')));
    })
        .then((value) => setState(() {
      _inProgress = false;
      resetValues();
    }))
        .catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fail')));
    });
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
