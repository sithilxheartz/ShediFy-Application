import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmployeePage extends StatefulWidget {
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  String? selectedPosition = 'Diesel_Pumper';

  Future<void> _addEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/add-employee"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "position": selectedPosition,
        "contactNumber": contactController.text,
        "salary": salaryController.text,
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Employee Added Successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${responseData["message"]}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Add New Pumpers",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          leading: IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context); // Correct back navigation
            },
          ),
          backgroundColor: Color.fromARGB(255, 39, 9, 171),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedPosition,
                items:
                    ["Diesel_Pumper", "Petrol_Pumper", "Manager"].map((
                      String category,
                    ) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged:
                    (newValue) => setState(() => selectedPosition = newValue),
                decoration: InputDecoration(labelText: "Position"),
              ),
              TextFormField(
                controller: contactController,
                decoration: InputDecoration(labelText: "Contact Number"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: salaryController,
                decoration: InputDecoration(labelText: "Salary"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 39, 9, 171),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  elevation: 4,
                ),
                onPressed: _addEmployee,
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
