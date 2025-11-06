
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CRDScreen extends StatefulWidget {
  const CRDScreen({super.key});

  @override
  State<CRDScreen> createState() => _CRDScreenState();
}

class _CRDScreenState extends State<CRDScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController rollnum = TextEditingController();

  List post = [];
  final String baseUrl = "https://api1-6e4a3-default-rtdb.firebaseio.com/api1";

  @override
  void initState() {
    super.initState();
    getBooks();
  }

  // CREATE operation
  Future<void> createData() async {
    try {
      var response = await http.post(
          Uri.parse("$baseUrl.json"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": name.text,
            "rollnumber": rollnum.text
          })
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data added successfully")));
        getBooks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add data")));
      }
    } catch (k) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $k")));
    }
    name.clear();
    rollnum.clear();
  }



  Future<void> getBooks() async {
    try {
      var response = await http.get(Uri.parse("$baseUrl.json"));
      if (response.statusCode == 200) {
        var bodyData = jsonDecode(response.body);
        if (bodyData is Map) {
          post = bodyData.entries.map((entry) {
            var value = entry.value;
            if (value is Map) {
              return {
                "id": entry.key,
                "name": value["name"] ?? "",
                "rollnumber": value["rollnumber"] ?? value["roll num"] ?? "",
              };
            } else if (value is List) {
              return {
                "id": entry.key,
                "name": "",
                "rollnumber": "",
              };
            } else {
              return {
                "id": entry.key,
                "name": value.toString(),
                "rollnumber": "",
              };
            }
          }).toList();
        } else {
          post = [];
        }

        setState(() {});
        print("Fetched ${post.length} records");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch data: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // UPDATE operation
  Future<void> updateData(String id) async {
    try {
      var response = await http.patch(
          Uri.parse("$baseUrl/$id.json"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": name.text,
            "rollnumber": rollnum.text
          })
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data updated")));
        setState(() {
          getBooks();
        });
      }
    } catch (c) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $c")));
    }
  }

  // DELETE operation
  Future<void> deleteData(String id) async {
    try {
      var response = await http.delete(Uri.parse("$baseUrl/$id.json"));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data deleted")));
        getBooks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete data")));
      }
    } catch (d) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $d")));
    }
  }

  // Edit dialog
  void showEditDialog(Map book) {
    TextEditingController editNameController = TextEditingController(text: book['name']);
    TextEditingController editRollnumController = TextEditingController(text: book['rollnumber']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Edit Data"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: editNameController,
                  decoration: InputDecoration(
                    hintText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: editRollnumController,
                  decoration: InputDecoration(
                    hintText: "Roll Number",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Update the main controllers and call update
                name.text = editNameController.text;
                rollnum.text = editRollnumController.text;
                updateData(book['id']);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTUcB3L1jzD_eLQ5tpvVs9uie6yBgQDStqG0w&s"),
                fit: BoxFit.cover
            )
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: name,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: "Enter your name",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: rollnum,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.numbers),
                  hintText: "Roll number",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: createData,
                child: Text("Add Data")
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: post.length,
                itemBuilder: (context, index) {
                  final item = post[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${item['name']}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              )
                          ),
                          Text("Roll Number: ${item['rollnumber']}"),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showEditDialog(item);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text("Edit"),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  bool? confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Confirm Delete"),
                                      content: Text("Are you sure you want to delete this data?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text("No")
                                        ),
                                        TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: Text("Yes")
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    deleteData(item['id']);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text("Delete"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}