import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add.dart';

class Adopt extends StatefulWidget {
  const Adopt({super.key});

  @override
  State<Adopt> createState() => _AdoptState();
}

class _AdoptState extends State<Adopt> {
  List? pets;


  final List<Map<String, String>> demoPets = [
    {"name": "Luna", "type": "ADOPT_Cat", "age": "2", "image_url": "https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=600"},
    {"name": "Rocky", "type": "ADOPT_Dog", "age": "4", "image_url": "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=600"},
    {"name": "Tweety", "type": "ADOPT_Bird", "age": "1", "image_url": "https://images.pexels.com/photos/1661179/pexels-photo-1661179.jpeg?auto=compress&cs=tinysrgb&w=600"},
    {"name": "Bella", "type": "ADOPT_Rabbit", "age": "1", "image_url": "https://images.pexels.com/photos/326012/pexels-photo-326012.jpeg"},
    {"name": "Sheldon", "type": "ADOPT_Turtle", "age": "10", "image_url": "https://images.pexels.com/photos/1618606/pexels-photo-1618606.jpeg?auto=compress&cs=tinysrgb&w=600"},
    {"name": "Rio", "type": "ADOPT_Parrot", "age": "3", "image_url": "https://images.pexels.com/photos/2317904/pexels-photo-2317904.jpeg?auto=compress&cs=tinysrgb&w=600"},
    {"name": "Nibbles", "type": "ADOPT_Hamster", "age": "1", "image_url": "https://images.pexels.com/photos/33914110/pexels-photo-33914110.jpeg"},
    {"name": "Max", "type": "ADOPT_Dog", "age": "5", "image_url": "https://images.pexels.com/photos/2253275/pexels-photo-2253275.jpeg?auto=compress&cs=tinysrgb&w=600"},
    {"name": "Oreo", "type": "ADOPT_Cat", "age": "2", "image_url": "https://images.pexels.com/photos/208984/pexels-photo-208984.jpeg"},
    {"name": "Goldie", "type": "ADOPT_Fish", "age": "1", "image_url": "https://images.pexels.com/photos/1894349/pexels-photo-1894349.jpeg"},
  ];

  Future<void> loadDemoData() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Restocking Shelter...")));
    var url = Uri.parse("http://obayna.atwebpages.com/save.php");
    for (var pet in demoPets) {
      try { await http.post(url, body: pet); } catch (e) { debugPrint("Error: $e"); }
    }
    getPets();
  }

  Future getPets() async {
    try {
      var url = Uri.parse("http://obayna.atwebpages.com/index.php");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() { pets = json.decode(response.body); });
      }
    } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> deletePet(String id) async {
    try {
      var url = Uri.parse("http://obayna.atwebpages.com/delete.php");
      await http.post(url, body: {"id": id});
      getPets();
    } catch (e) { debugPrint("Error: $e"); }
  }


  Future<void> processAdoption(Map pet) async {
    String cleanType = pet['type'].toString().replaceAll("ADOPT_", "");
    try {
      var url = Uri.parse("http://obayna.atwebpages.com/save.php");
      var response = await http.post(url, body: {
        "name": pet['name'],
        "type": cleanType,
        "age": pet['age'].toString(),
        "image_url": pet['image_url'] ?? ""
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Congratulations! ${pet['name']} is now in your tracker."), backgroundColor: Colors.green)
        );
      }
    } catch (e) { debugPrint("Error adopting: $e"); }
  }

  void confirmAdoption(Map pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Adopt ${pet['name']}?"),
        content: Text("Add ${pet['name']} to your tracker?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => processAdoption(pet),
              child: const Text("YES, ADOPT!", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }


  void showPetDetails(Map pet, String description) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: (pet['image_url'] != null && pet['image_url'] != "")
                      ? Image.network(pet['image_url'], fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.pets, size: 80, color: Colors.grey))
                      : const Icon(Icons.pets, size: 80, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(pet['name'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text("${pet['age']} years old • ${pet['type'].toString().replaceAll("ADOPT_", "")}", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 16),
                    Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.4)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE"))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            onPressed: () {
                              Navigator.pop(context);
                              confirmAdoption(pet);
                            },
                            child: const Text("ADOPT", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Listing?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(onPressed: () { Navigator.pop(context); deletePet(id); }, child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  String getDescription(String name, String type) {
    String cleanType = type.toLowerCase();
    List<String> options = [];
    if (cleanType.contains("cat")) {
      options = ["Loves naps in the sun and chasing lasers.", "Independent, clean, and purrs loudly.", "Looking for a warm lap to sleep on."];
    } else if (cleanType.contains("dog")) {
      options = ["Loyal best friend who loves long walks.", "Great at playing fetch and knows tricks.", "Protective, friendly, and house-trained."];
    } else {
      options = ["Cute, fuzzy, and loves fresh veggies.", "Small but full of personality!", "Quiet companion looking for a home."];
    }
    return options[name.length % options.length];
  }

  @override
  void initState() { getPets(); super.initState(); }

  @override
  Widget build(BuildContext context) {
    List adoptionPets = [];
    if (pets != null) {
      adoptionPets = pets!.where((p) => p['type'].toString().startsWith("ADOPT_")).toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Adoption Center"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(onPressed: loadDemoData, icon: const Icon(Icons.flash_on)),
          IconButton(onPressed: getPets, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const Add(isAdoption: true)));
          getPets();
        },
        label: const Text("List a Pet"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      body: pets == null
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280,
            childAspectRatio: 0.70,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: adoptionPets.length,
          itemBuilder: (context, index) {
            var pet = adoptionPets[index];
            String displayType = pet['type'].toString().replaceAll("ADOPT_", "");
            String dynamicDescription = getDescription(pet['name'], displayType);

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (pet['image_url'] != null && pet['image_url'] != "")
                            Image.network(pet['image_url'], fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[200], child: const Icon(Icons.pets, color: Colors.grey)))
                          else
                            Container(color: Colors.orange[100], child: const Icon(Icons.pets, color: Colors.orange)),

                          Positioned(
                            top: 8, right: 8,
                            child: InkWell(
                              onTap: () => confirmDelete(pet['id'].toString()),
                              child: const CircleAvatar(backgroundColor: Colors.white, radius: 12, child: Icon(Icons.close, color: Colors.red, size: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),


                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Expanded(child: Text(pet['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1)),
                              Text("${pet['age']} yrs", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                            ]),
                            Text(displayType, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                            const Spacer(),
                            Text(dynamicDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                            const Spacer(),


                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      side: const BorderSide(color: Colors.orange),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => showPetDetails(pet, dynamicDescription),
                                    child: const Text("INFO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.orange,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => confirmAdoption(pet),
                                    child: const Text("ADOPT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}