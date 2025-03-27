import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dashboardMain.dart';
import 'productUpdateStock.dart';
import 'productDetails.dart';
import 'productAddNew.dart';

class OilShopApp extends StatefulWidget {
  @override
  _OilShopAppState createState() => _OilShopAppState();
}

class _OilShopAppState extends State<OilShopApp> {
  String? userRole;
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _fetchProducts();
  }

  Future<void> _getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? "user";
    });
  }

  Future<void> _fetchProducts() async {
    try {
      var response = await http.get(
        Uri.parse("http://10.0.2.2:5000/inventory"),
      );

      if (response.statusCode == 200) {
        setState(() {
          products = List<Map<String, dynamic>>.from(
            json.decode(response.body),
          );
          isLoading = false;
        });
      } else {
        _showMessage("Failed to fetch products");
      }
    } catch (e) {
      _showMessage("Error fetching products: $e");
    }
  }

  Future<void> _updateStock(int productId, String newStock) async {
    try {
      var response = await http.put(
        Uri.parse("http://10.0.2.2:5000/inventory/$productId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"stockQuantity": int.parse(newStock)}),
      );

      if (response.statusCode == 200) {
        _showMessage("Stock updated successfully!");
        _fetchProducts(); // Refresh products after update
      } else {
        _showMessage("Failed to update stock");
      }
    } catch (e) {
      _showMessage("Error updating stock: $e");
    }
  }

  Future<void> _deleteProduct(int productId) async {
    try {
      var response = await http.delete(
        Uri.parse("http://10.0.2.2:5000/inventory/$productId"),
      );

      if (response.statusCode == 200) {
        _showMessage("Product deleted successfully!");
        _fetchProducts(); // Refresh products after deletion
      } else {
        _showMessage("Failed to delete product");
      }
    } catch (e) {
      _showMessage("Error deleting product: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
              "Oil Shop",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
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
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount:
                      userRole == "admin"
                          ? products.length + 1
                          : products.length,
                  itemBuilder: (context, index) {
                    if (userRole == "admin" && index == products.length) {
                      return _buildMenuItem(
                        context,
                        Icons.add,
                        "Add Product",
                        AddNewProduct(),
                      );
                    } else {
                      return _buildProductItem(context, products[index]);
                    }
                  },
                ),
              ),
    );
  }

  Widget _buildProductItem(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetails(product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
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
            const Icon(Icons.oil_barrel, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                product['productName'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              " ${product['productName']}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            //Text("Stock: ${product['stockQuantity']}", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            if (userRole == "admin") ...[
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UpdateStockPage(
                            updateStock: _updateStock,
                            productId: product['productID'],
                          ),
                    ),
                  );
                },
                child: const Text("Update Stock"),
              ),
              ElevatedButton(
                onPressed: () => _deleteProduct(product['productID']),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
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
      onTap: () async {
        bool? productAdded = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );

        // If a product was added, refresh the list
        if (productAdded == true) {
          _fetchProducts();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
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
            Icon(icon, size: 50),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
