import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  List<dynamic> userTypes = [];
  String? selectedUserType;
  bool? isStudent;
  bool isLoading = false;
  List<dynamic> savedData = [];
  List userList = [];
  List<String> users = [];

  @override
  void initState() {
    super.initState();
    fetchUserTypes();
  }

  Future<void> fetchUserTypes() async {
    try {
      var response = await http.get(
        Uri.parse("http://92.205.109.210:8031/Test/GetUserType"),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        userList = data["list"];
        print(userList);
        setState(() {
          for (var x in userList) {
            String user1 = x["userType"];
            users.add(user1);
          }
        });
        print(users);
      } else {
        debugPrint("Failed to load user types");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
  Future<void> submitForm() async {
    if (selectedUserType == true|| isStudent == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all fields")),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://92.205.109.210:8031/Test/InsertTestDtls"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userType": selectedUserType,
          "is_student": isStudent,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          savedData.add({
            "userType": selectedUserType!,
            "is_student": isStudent,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data saved successfully!")),
        );


        setState(() {
          selectedUserType = null;
          isStudent=null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save data (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DATA Handling"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Select Role:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<String>(
                value: selectedUserType,
                isExpanded: true,
                underline: SizedBox(),
                hint: Text("Select User Type"),
                items: users.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUserType = newValue;
                  });
                },
              ),
            ),
             SizedBox(height: 20),
             Text(
              "Select True or False:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title:  Text('True'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: isStudent,
                      onChanged: (bool? value) {
                        setState(() {
                          isStudent = value;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('False'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: isStudent,
                      onChanged: (bool? value) {
                        setState(() {
                          isStudent = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
             SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: isLoading
                    ?  SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    :  Text(
                  'Submit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (savedData.isNotEmpty) ...[
               Text(
                "Saved Data:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
               SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: savedData.length,
                  itemBuilder: (context, index) {
                    final data = savedData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text("User Type: ${data['userType'] ?? 'N/A'}"),
                        subtitle: Text("Is Student: ${data['is_student'] == 1 ? 'True' : 'False'}"),
                        trailing: Text("ID: ${data['id'] ?? 'N/A'}"),
                      ),
                    );
                  },
                ),
              ),
            ] else if (!isLoading && users.isEmpty)
              const Center(
                child: Text(
                  "No user types found. Please check the server connection.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}