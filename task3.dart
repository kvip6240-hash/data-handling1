import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Task3 extends StatefulWidget {
  final Map<String, dynamic> selectedProducts;

  const Task3({super.key, required this.selectedProducts});

  @override
  State<Task3> createState() => _Task3State();
}

class _Task3State extends State<Task3> {
  Map<String, dynamic>? singleProduct;
  bool isLoading = false;
  bool isUpdating = false;
  bool isDeleting = false;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSingleProduct();
  }

  // Fetch product with ID 1
  Future<void> fetchSingleProduct() async {
    setState(() {
      isLoading = true;
    });

    try {
      Response response = await Dio().get("https://api.restful-api.dev/objects/1");
      setState(() {
        singleProduct = response.data;
        // Pre-fill form with current data
        if (singleProduct != null) {
          nameController.text = singleProduct!["name"] ?? "";
          priceController.text = singleProduct!["data"]?["price"]?.toString() ?? "";
          colorController.text = singleProduct!["data"]?["color"]?.toString() ?? "";
          capacityController.text = singleProduct!["data"]?["capacity"]?.toString() ?? "";
        }
      });
    } catch (e) {
      print("Error fetching single product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching product: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update product
  Future<void> updateProduct() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name is required')),
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      var updateData = {
        "name": nameController.text,
        "data": {
          if (priceController.text.isNotEmpty) "price": double.tryParse(priceController.text),
          if (colorController.text.isNotEmpty) "color": colorController.text,
          if (capacityController.text.isNotEmpty) "capacity": capacityController.text,
        }
      };

      Response response = await Dio().put(
        "https://api.restful-api.dev/objects/7",
        data: updateData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );

      // Refresh the product data
      fetchSingleProduct();

    } catch (e) {
      print("Error updating product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  // Delete product
  Future<void> deleteProduct() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await Dio().delete("https://api.restful-api.dev/objects/6");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );

      // Clear the form after deletion
      nameController.clear();
      priceController.clear();
      colorController.clear();
      capacityController.clear();
      setState(() {
        singleProduct = null;
      });

    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details & Management"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Products from previous page
            if (widget.selectedProducts.isNotEmpty) ...[
              const Text(
                "Selected Products:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...widget.selectedProducts.entries.map((entry) {
                var product = entry.value;
                var data = product["data"] ?? {};
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                    title: Text(product["name"] ?? "No name"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data["brand"] != null) Text("Brand: ${data["brand"]}"),
                        if (data["color"] != null) Text("Color: ${data["color"]}"),
                        if (data["capacity"] != null) Text("Capacity: ${data["capacity"]}"),
                        Text("ID: ${product["id"]}"),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const Divider(height: 30),
            ],

            // Single Product Details (ID 1)
            const Text(
              "Product Details (ID 1):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (singleProduct != null)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        singleProduct!["name"] ?? "No Name",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text("ID: ${singleProduct!["id"]}"),
                      if (singleProduct!["data"] != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Details:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...singleProduct!["data"].entries.map((entry) {
                          return Text("${entry.key}: ${entry.value}");
                        }).toList(),
                      ],
                      if (singleProduct!["createdAt"] != null)
                        Text("Created: ${singleProduct!["createdAt"]}"),
                      if (singleProduct!["updatedAt"] != null)
                        Text("Updated: ${singleProduct!["updatedAt"]}"),
                    ],
                  ),
                ),
              )
            else
              const Text("No product data available"),

            const SizedBox(height: 30),

            // Update Product Form
            const Text(
              "Update Product (ID 7):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isUpdating ? null : updateProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: isUpdating
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text('Update Product', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isDeleting ? null : deleteProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: isDeleting
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text('Delete Product', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    colorController.dispose();
    capacityController.dispose();
    super.dispose();
  }
}