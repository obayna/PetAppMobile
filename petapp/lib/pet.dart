import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


class Pet {
  final String name;
  final String type;
  final String age;

  Pet(this.name, this.type, this.age);
}


List<Pet> _pets = [];


void updatePets(Function(bool) callback) async {
  try {
    final url = Uri.parse('http://obayna.atwebpages.com/index.php');
    final response = await http.get(url).timeout(const Duration(seconds: 5));

    _pets.clear();
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      for (var item in data) {
        _pets.add(Pet(
          item['name'].toString(),
          item['type'].toString(),
          item['age'].toString(),
        ));
      }
      callback(true);
    } else {
      callback(false);
    }
  } catch (e) {
    callback(false);
  }
}


class ShowPets extends StatelessWidget {
  const ShowPets({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _pets.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_pets[index].name),
        subtitle: Text("${_pets[index].type} - ${_pets[index].age} years old"),
      ),
    );
  }
}