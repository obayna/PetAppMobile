import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';
import 'add.dart';
import 'vaccine.dart';
import 'adopt.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 0;
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
      debugPrint("Error loading pets: $e");
    }
  }

  Future<void> deletePet(String id) async {
    try {
      var url = Uri.parse("http://obayna.atwebpages.com/delete.php");
      await http.post(url, body: {"id": id});
      getPets();
    } catch (e) {
      debugPrint("Error deleting: $e");
    }
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Pet?"),
        content: const Text("Stop tracking this pet?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deletePet(id);
            },
            child: const Text("REMOVE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 3. LOGOUT
  Future<void> logout() async {
    await storage.delete(key: "session");
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
  }

  @override
  void initState() {
    super.initState();
    getPets();
  }


  Widget _buildTrackerPage() {
    // FILTER: Only show YOUR pets
    List myPets = [];
    if (pets != null) {
      myPets = pets!.where((p) => !p['type'].toString().startsWith("ADOPT_")).toList();
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: pets == null
            ? const Center(child: CircularProgressIndicator())
            : myPets.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off_outlined, size: 80, color: Colors.blue[200]),
              const SizedBox(height: 20),
              const Text("No medical records found.", style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: myPets.length,
          itemBuilder: (context, index) {
            var pet = myPets[index];

            return Container(
              height: 160,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [

                  SizedBox(
                    width: 160,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: (pet['image_url'] != null && pet['image_url'].toString().isNotEmpty)
                          ? Image.network(
                        pet['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.pets, size: 50, color: Colors.blue[100]),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.pets, size: 50, color: Colors.blue[100]),
                      ),
                    ),
                  ),


                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pet['name'],
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => confirmDelete(pet['id'].toString()),
                                tooltip: "Remove Pet",
                              )
                            ],
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pet['type'],
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                            ),
                          ),

                          const Spacer(),

                          SizedBox(
                            height: 36,
                            width: 180,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VaccineScreen(
                                      petName: pet['name'],
                                      petType: pet['type'],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.medical_services, size: 16, color: Colors.white),
                              label: const Text("VIEW VACCINES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.blue[50],


      appBar: _currentIndex == 0 ? AppBar(
        title: const Text("My Pet Tracker"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(onPressed: getPets, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ) : null,


      floatingActionButton: _currentIndex == 0 ? FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const Add(isAdoption: false)));
          getPets();
        },
        label: const Text("Add Pet"),
        icon: const Icon(Icons.pets),
        backgroundColor: Colors.blueAccent,
      ) : null,


      body: _currentIndex == 0
          ? _buildTrackerPage()
          : const Adopt(),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) getPets();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: "My Tracker",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Adoption",
          ),
        ],
      ),
    );
  }
}