import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'task3.dart'; // Import the task3 page

class Task1 extends StatefulWidget {
  const Task1({super.key});

  @override
  State<Task1> createState() => _Task1State();
}

class _Task1State extends State<Task1> {
  List<dynamic> products = [];
  Set<String> selectedIds = {}; // Track selected item IDs
  Map<String, dynamic> selectedProductsMap = {}; // Store selected products data

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      Response response = await Dio().get("https://api.restful-api.dev/objects");
      setState(() {
        products = response.data;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // Toggle selection for an item
  void toggleSelection(String id, dynamic productData) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
        selectedProductsMap.remove(id);
      } else {
        selectedIds.add(id);
        selectedProductsMap[id] = productData;
      }
    });
  }

  // Navigate to next page with selected data
  void goToNextPage() {
    if (selectedIds.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Task3(selectedProducts: selectedProductsMap),
        ),
      );
    } else {
      // Show message if no products selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selected Products"),
        backgroundColor: Colors.blue,
      ),
      body: products.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          var product = products[index];
          var data = product["data"] ?? {};
          String productId = product["id"]?.toString() ?? "";
          bool isSelected = selectedIds.contains(productId);

          return GestureDetector(
            onTap: () => toggleSelection(productId, product),
            child: Card(
              margin: const EdgeInsets.all(8),
              color: isSelected ? Colors.blue.shade100 : Colors.white,
              elevation: isSelected ? 4 : 1,
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.shopping_bag,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                title: Text(
                  product["name"] ?? "No name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue.shade800 : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Brand: ${data["brand"] ?? "No brand"}",
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.blue.shade600 : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "ID: ${product["id"] ?? ""}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue.shade500 : Colors.grey.shade600,
                      ),
                    ),
                    if (data["color"] != null)
                      Text(
                        "Color: ${data["color"]}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.blue.shade500 : Colors.grey.shade600,
                        ),
                      ),
                    if (data["capacity"] != null)
                      Text(
                        "Capacity: ${data["capacity"]}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.blue.shade500 : Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
              ),
            ),
          );
        },
      ),
      // Floating action button to navigate to next page
      floatingActionButton: selectedIds.isNotEmpty
          ? FloatingActionButton(
        onPressed: goToNextPage,
        child: Badge(
          label: Text(selectedIds.length.toString()),
          child: const Icon(Icons.arrow_forward),
        ),
      )
          : null,
    );
  }
}