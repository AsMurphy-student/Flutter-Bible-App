import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'bible.dart';
import 'settings.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Prefs
  late SharedPreferences prefs;
  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getInt('currentBottomTab') != null) {
        currentBottomTab = prefs.getInt('currentBottomTab')!;
      }
      if (prefs.getInt('currentBook') != null) {
        currentBook = prefs.getInt('currentBook')!;
      }
    });

    getBooks(
      'https://bible.helloao.org/api/${prefs.getString('chosenTranslation') ?? "eng_asv"}/books.json',
    );
  }

  Future<void> saveValue(String key, dynamic value) async {
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> getBooks(String fetchURL) async {
    // Get response and assign variables accordingly
    var response = await http.get(Uri.parse(fetchURL));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['books'];

      setState(() {
        bookIDs = data.map((element) => element['id'].toString()).toList();
      });
    } else {
      print("Theres a problem: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  int currentBottomTab = 0;
  int currentBook = 0;
  late List<String> bookIDs;

  List<Widget> get bottomNavScreens => [
    PageHome(chapterTitle: bookIDs.isNotEmpty ? bookIDs[currentBook] : 'GEN'),
    PageSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${bookIDs.isNotEmpty ? bookIDs[currentBook] : 'Fetching IDs'} chapter (ex. John 5)",
        ),
        leading: DropdownButton<String>(
          value: bookIDs.isNotEmpty ? bookIDs[currentBook] : 'GEN',
          icon: Icon(Icons.arrow_downward),
          onChanged: (String? newValue) {
            setState(() {
              currentBook = bookIDs.indexOf(newValue!);
              saveValue('currentBook', bookIDs.indexOf(newValue));
            });
          },
          items: bookIDs.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                if (currentBook > 0) {
                  currentBook -= 1;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                if (currentBook <= 66) {
                  currentBook += 1;
                }
              });
            },
          ),
        ],
      ),
      body: IndexedStack(index: currentBottomTab, children: bottomNavScreens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: currentBottomTab,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Bible",
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
            backgroundColor: Colors.green,
          ),
        ],
        onTap: (value) {
          setState(() {
            currentBottomTab = value;
            saveValue('currentBottomTab', value);
          });
        },
      ),
    );
  }
}
