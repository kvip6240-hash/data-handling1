import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class task11 extends StatefulWidget {
  const task11({super.key});

  @override
  State<task11> createState() => _task11State();
}

class _task11State extends State<task11> {
  List a = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      Response response = await Dio().get("https://api.restful-api.dev/objects");

      setState(() {
        a = response.data;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  delete()async{

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("API")),
      body: ListView.builder(
        itemCount: a.length,
        itemBuilder: (context, index) {
          var item = a[index];
          var data = item["data"] ?? {};
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item["name"] ?? "No name"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ID: ${item["id"] ?? ""}"),
                  Text("Color: ${data["color"]}"),
                  Text("Capacity: ${data["capacity"]}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}