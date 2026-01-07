import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddVaccine extends StatefulWidget {

  final String petId;

  const AddVaccine({super.key, required this.petId});

  @override
  State<AddVaccine> createState() => _AddVaccineState();
}

class _AddVaccineState extends State<AddVaccine> {

  final _vaccineController = TextEditingController();
  final _dateController = TextEditingController();

  Future<void> saveVaccine() async {

    if (_vaccineController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {

      var url = Uri.parse("http://obayna.atwebpages.com/add_vaccine.php");

      var response = await http.post(url, body: {
        "pet_id": widget.petId,
        "vaccine_name": _vaccineController.text,
        "date_given": _dateController.text,
      });

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vaccine Added!")));
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Vaccine"), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.medical_services, size: 60, color: Colors.blueAccent),
            const SizedBox(height: 20),


            TextField(
                controller: _vaccineController,
                decoration: const InputDecoration(labelText: "Vaccine Name", border: OutlineInputBorder())
            ),
            const SizedBox(height: 15),

            TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date (YYYY-MM-DD)", border: OutlineInputBorder())
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveVaccine,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("SAVE RECORD", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}