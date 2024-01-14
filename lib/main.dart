import 'package:amahoro_player_registration/screens/add-player-screen.dart';
import 'package:amahoro_player_registration/screens/showPlayerCards.dart';
import 'package:amahoro_player_registration/screens/view-player-cards-screen.dart';
import 'package:amahoro_player_registration/screens/view-player-screen.dart';
import 'package:amahoro_player_registration/screens/view-player-screen2.dart';
import 'package:amahoro_player_registration/theme/colors.dart';
import 'package:amahoro_player_registration/theme/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xffa37765, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
          <int, Color>{
            50: Color(0xffe3d6d1), //10%
            100: Color(0xffd1bbb2), //20%
            200: Color(0xffbfa093), //30%
            300: Color(0xffac8574), //40%
            400: Color(0xffa37765), //50%
            500: Color(0xff825f51), //60%
            600: Color(0xff725347), //70%
            700: Color(0xff62473d), //80%
            800: Color(0xff413028), //90%
            900: Color(0xff211814), //100%
          },
        ),
      ),
      home: const MyHomePage(title: 'Amahoro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndexDesktop = 0;

  static const List<Widget> _screensDesktop = <Widget>[
    ViewPlayerScreen2(),
    AddPlayerScreen(),
    ViewPlayerCards(),
    ViewPlayerScreen(),
    TeamSelectionPage(
        leagueDocID: 'bCQQ0U7Ir8zSZFDU6Kv6',
        seasonDocID: 'Beu81BmZ8OZeHqGheuZO')
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndexDesktop = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _screensDesktop.elementAt(_selectedIndexDesktop),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: kDefaultTextStyle11pt,
        unselectedLabelStyle: kDefaultTextStyle11pt,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: 'Kimisagara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_search),
            label: 'Player Cards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Player List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Card list',
          ),
        ],
        currentIndex: _selectedIndexDesktop,
        selectedItemColor: kAmahoroColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
