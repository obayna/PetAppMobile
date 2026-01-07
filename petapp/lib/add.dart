import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Add extends StatefulWidget {
  final bool isAdoption;
  const Add({super.key, required this.isAdoption});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();


  File? _pickedImage;
  String selectedAvatarUrl = "";
  String selectedType = 'Cat';


  final List<String> petTypes = ['Cat', 'Dog', 'Bird', 'Hamster', 'Fish', 'Other'];


  final List<String> dogAvatars = [
    "https://cdn-icons-png.flaticon.com/512/616/616408.png",
    "https://cdn-icons-png.flaticon.com/512/194/194279.png",
    "https://cdn-icons-png.flaticon.com/512/2829/2829818.png",
    "https://cdn-icons-png.flaticon.com/512/616/616554.png",
  ];

  final List<String> catAvatars = [
    "https://cdn-icons-png.flaticon.com/512/616/616430.png",
    "https://cdn-icons-png.flaticon.com/512/1864/1864514.png",
    "https://cdn-icons-png.flaticon.com/512/1998/1998627.png",
    "https://cdn-icons-png.flaticon.com/512/616/616569.png",
  ];

  final List<String> birdAvatars = [
    "https://cdn-icons-png.flaticon.com/512/616/616422.png",
    "https://cdn-icons-png.flaticon.com/512/826/826908.png",
    "https://cdn-icons-png.flaticon.com/512/3069/3069172.png",
    "https://cdn-icons-png.flaticon.com/512/3069/3069186.png",
  ];


  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        selectedAvatarUrl = "";
      });
    }
  }

  Future<String?> uploadRealImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse("http://obayna.atwebpages.com/upload_image.php")
      );

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var res = await request.send();

      if (res.statusCode == 200) {
        var responseData = await res.stream.bytesToString();
        return responseData;
      }
    } catch (e) {
      debugPrint("Upload error: $e");
    }
    return null;
  }


  Future<void> savePet() async {
    if (nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name is required")));
      return;
    }


    String finalImageUrl = "https://cdn-icons-png.flaticon.com/512/12/12638.png";


    if (_pickedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading image...")));
      String? uploadedUrl = await uploadRealImage(_pickedImage!);
      if (uploadedUrl != null) finalImageUrl = uploadedUrl;
    } else if (selectedAvatarUrl.isNotEmpty) {
      finalImageUrl = selectedAvatarUrl;
    }


    String finalType = widget.isAdoption ? "ADOPT_$selectedType" : selectedType;

    try {
      var url = Uri.parse("http://obayna.atwebpages.com/save.php");

      var response = await http.post(url, body: {
        "name": nameCtrl.text,
        "type": finalType,
        "age": ageCtrl.text,
        "image_url": finalImageUrl,
      });

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error saving: $e");
    }
  }

  IconData getIconForType(String type) {
    switch (type) {
      case 'Cat': return Icons.pets;
      case 'Dog': return Icons.cruelty_free;
      case 'Bird': return Icons.flutter_dash;
      case 'Fish': return Icons.water;
      case 'Hamster': return Icons.bedroom_baby;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdopt = widget.isAdoption;

    List<String> currentAvatars = [];
    if (selectedType == "Cat") currentAvatars = catAvatars;
    if (selectedType == "Dog") currentAvatars = dogAvatars;
    if (selectedType == "Bird") currentAvatars = birdAvatars;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdopt ? "List for Adoption" : "Add Private Pet"),
        backgroundColor: isAdopt ? Colors.orange : Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Pet Name")),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: "Select Pet Type",
                border: OutlineInputBorder(),
              ),
              items: petTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(getIconForType(type), color: Colors.grey[600]),
                      const SizedBox(width: 10),
                      Text(type),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue!;
                  selectedAvatarUrl = "";
                });
              },
            ),
            const SizedBox(height: 15),

            TextField(
              controller: ageCtrl,
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),

            const Text("Pet Photo", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            InkWell(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                    image: _pickedImage != null
                        ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
                        : null
                ),
                child: _pickedImage == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                    Text("Tap to Upload from Gallery"),
                  ],
                )
                    : null,
              ),
            ),
            if (currentAvatars.isNotEmpty && _pickedImage == null) ...[
              const SizedBox(height: 20),
              const Text("Or choose an Avatar:", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentAvatars.length,
                  itemBuilder: (context, index) {
                    String url = currentAvatars[index];
                    bool isSelected = (selectedAvatarUrl == url);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatarUrl = url;
                          _pickedImage = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(url),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: isAdopt ? Colors.orange : Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: savePet,
                child: const Text("SAVE PET", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}