import 'package:flutter/material.dart';
import 'addNewPumper.dart';
import 'shiftAssignPage.dart';
import 'fuelStockUpdate.dart';

class ManagementMenu extends StatelessWidget {
  const ManagementMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Management",
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
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildMenuItem(
              context,
              Icons.people,
              "Add Pumpers",
              EmployeePage(),
            ),
            _buildMenuItem(
              context,
              Icons.assignment,
              "Assign Shifts",
              AssignShiftPage(),
            ),
            _buildMenuItem(
              context,
              Icons.add,
              "Add Fuel Stock",
              AddFuelStockPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 39, 9, 171),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
