import 'package:flutter/material.dart';

class ViewPlayerScreen extends StatefulWidget {
  const ViewPlayerScreen({Key? key}) : super(key: key);

  @override
  _ViewPlayerScreenState createState() => _ViewPlayerScreenState();
}

class _ViewPlayerScreenState extends State<ViewPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Text(
        'Index 1: View',
      ),
    );
  }
}