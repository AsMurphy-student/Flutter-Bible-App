import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Translationdropdown extends StatefulWidget {
  const Translationdropdown({super.key});

  @override
  State<Translationdropdown> createState() => _TranslationdropdownState();
}

class _TranslationdropdownState extends State<Translationdropdown> {
  String dropdownValue = 'eng_asv';
  List<String> translationCodes = [];

  Future<void> getTranslations(String fetchURL) async {
    // Get response and assign variables accordingly
    var response = await http.get(Uri.parse(fetchURL));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['translations'];
      List<dynamic> filteredData = data
          .where(
            (object) =>
                object['language'] == 'eng' && object['numberOfBooks'] == 66,
          )
          .toList();

      setState(() {
        translationCodes = filteredData
          .map((translation) => translation['id'].toString())
          .toList();
      });
    } else {
      print("Theres a problem: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();

    getTranslations(
      'https://bible.helloao.org/api/available_translations.json',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Translation:"),
        DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(Icons.arrow_downward),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
          items: translationCodes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ],
    );
  }
}
