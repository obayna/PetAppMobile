import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'add.dart';
import 'add_vaccine.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storage = const FlutterSecureStorage();
  List? pets;

  Future getPets() async {
    try {
      var url = Uri.parse("http://obayna.atwebpages.com/index.php");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          pets = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching pets: $e");
    }
  }

  Future<void> deletePet(String id) async {
    try {
      var url = Uri.parse("http://obayna.atwebpages.com/delete.php");
      var response = await http.post(url, body: {"id": id});


      if (response.statusCode == 200) {
        setState(() {
          pets?.removeWhere((item) => item['id'].toString() == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pet Deleted")));
      }
    } catch (e) {
      debugPrint("Error deleting: $e");
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pet?"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () { Navigator.pop(context); deletePet(id); },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPetDetails(Map pet) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pet: ${pet['name']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),
              const Text("VACCINATION STATUS:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),

              Text("Vaccine: ${pet['vaccine_name'] ?? 'No record'}", style: const TextStyle(fontSize: 16)),
              Text("Date: ${pet['date_given'] ?? '--'}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("ADD VACCINE", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    Navigator.pop(context);
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddVaccine(petId: pet['id'].toString())));
                    getPets();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void logout() async {
    await storage.delete(key: "session");
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const Login()), (route) => false);
  }

  @override
  void initState() {
    getPets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Pet Tracker"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(onPressed: getPets, icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () async {

                await Navigator.push(context, MaterialPageRoute(builder: (context) => const Add(isAdoption: false)));
                getPets();
              },
              icon: const Icon(Icons.add)
          ),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: pets == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        itemCount: pets!.length,
        itemBuilder: (context, index) {


          if (pets![index]['type'].toString().startsWith("ADOPT_")) {
            return const SizedBox.shrink();
          }

          String displayType = pets![index]['type'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _showPetDetails(pets![index]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pets![index]['image_url'] != null && pets![index]['image_url'] != "")
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Image.network(
                        pets![index]['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 80,
                      width: double.infinity,
                      color: Colors.blue[50],
                      child: const Center(child: Icon(Icons.pets, size: 40, color: Colors.blueAccent)),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pets![index]['name'] ?? "Unknown", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),


                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                    displayType == 'Cat' ? Icons.pets :
                                    displayType == 'Dog' ? Icons.cruelty_free :
                                    displayType == 'Bird' ? Icons.flutter_dash :
                                    displayType == 'Fish' ? Icons.water :
                                    displayType == 'Hamster' ? Icons.bedroom_baby :
                                    Icons.help_outline,
                                    size: 16, color: Colors.grey
                                ),
                                const SizedBox(width: 5),
                                Text(displayType, style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => confirmDelete(pets![index]['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}