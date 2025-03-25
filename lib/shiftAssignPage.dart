import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AssignShiftPage extends StatefulWidget {
  @override
  _AssignShiftPageState createState() => _AssignShiftPageState();
}

class _AssignShiftPageState extends State<AssignShiftPage> {
  List<Map<String, dynamic>> employees = [];
  String? selectedEmployee;
  String? selectedShiftType;
  bool isNightShift = false;
  int? selectedPump;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:5000/get-employees"),
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> employeeList = List<Map<String, dynamic>>.from(
        json.decode(response.body),
      );
      setState(() {
        employees = employeeList;
        if (employees.isNotEmpty) {
          selectedEmployee =
              employees.first['employeeID'].toString(); // Set default employee
        }
      });
    }
  }

  Future<void> _assignShift() async {
    if (selectedEmployee == null ||
        selectedShiftType == null ||
        selectedPump == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/assign-shift"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "date": formattedDate,
        "employeeID": selectedEmployee,
        "shiftType": selectedShiftType,
        "nightShift": isNightShift ? 1 : 0,
        "pumpNumber": selectedPump,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Shift assigned successfully!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to assign shift")));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
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
              "Assign Shifts",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            if (employees.isEmpty)
              Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Select Employee"),
                value: selectedEmployee, // Use default employee
                items:
                    employees.map((e) {
                      return DropdownMenuItem<String>(
                        value: e['employeeID'].toString(),
                        child: Text(e['name']),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEmployee = value;
                  });
                },
              ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Shift Type"),
              value: selectedShiftType,
              items:
                  ["Diesel_Pumper", "Petrol_Pumper", "Other"].map((
                    String shift,
                  ) {
                    return DropdownMenuItem<String>(
                      value: shift,
                      child: Text(shift),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedShiftType = value;
                });
              },
            ),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: "Select Pump Number"),
              value: selectedPump,
              items:
                  List.generate(6, (index) => index + 1).map((int pump) {
                    return DropdownMenuItem<int>(
                      value: pump,
                      child: Text("Pump $pump"),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPump = value;
                });
              },
            ),
            SwitchListTile(
              title: Text("Night Shift"),
              value: isNightShift,
              onChanged: (value) {
                setState(() {
                  isNightShift = value;
                });
              },
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
              onPressed: _assignShift,
              child: Text(
                "Submit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
