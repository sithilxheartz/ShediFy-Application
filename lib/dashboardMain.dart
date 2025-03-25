import 'package:fillifyapp/main.dart';
import 'package:flutter/material.dart';
import 'fuelStockPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'productMenu.dart';
import 'shiftsViewPage.dart';
import 'dashboardManagement.dart';
import 'fuelSalesAdd.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? userName;
  String? userEmail;
  String? userRole;
  List<double> fuelLevels = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1]; // Dummy data
  final double tankCapacity = 13000;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role');

    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    setState(() {
      userRole = role;
    });

    // Fetch user data (name & email)
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/profile'),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['user']['name'];
          userEmail = data['user']['email'];
        });
      } else {
        _showMessage("Failed to fetch profile");
      }
    } catch (e) {
      _showMessage("Error fetching profile: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void updateFuelLevels(List<double> newLevels) {
    setState(() {
      fuelLevels = newLevels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          leading: Icon(Icons.abc, color: Color.fromARGB(255, 39, 9, 171)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          centerTitle: true,
          title: const Text(
            "ShediFY",
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),

          backgroundColor: Color.fromARGB(255, 39, 9, 171),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (userName != null && userEmail != null)
              Column(
                children: [
                  Text(
                    'Welcome, $userName..!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Role: ${userRole ?? "Unknown"}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: _buildMenuItems(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> menuItems = [
      _buildMenuItem(
        context,
        Icons.local_gas_station,
        "Fuel Stock",
        FuelStock(),
      ),
      _buildMenuItem(context, Icons.oil_barrel, "Oil Shop", OilShopApp()),
      _buildMenuItem(context, Icons.work, "Shifts View", ShiftSchedulePage()),
      _buildMenuItem(
        context,
        Icons.sell,
        "Add Fuel Sales",
        AddSalesPage(updateFuelLevels, fuelLevels, tankCapacity),
      ), // NEW MENU ITEM
    ];

    if (userRole == "admin") {
      // Only admins can see these options
      menuItems.add(
        _buildMenuItem(context, Icons.settings, "Management", ManagementMenu()),
      );
    }

    menuItems.add(
      _buildMenuItem(context, Icons.logout, "Logout", null, isLogout: true),
    );

    return menuItems;
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget? page, {
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          _logout();
        } else if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 39, 9, 171),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
