import 'package:apii/task2.dart';
import 'package:apii/task3.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'DATA handling.dart';
import 'apitask.dart';
import 'firebase_options.dart';
import 'home.dart';




Future<void> main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform
    );
    runApp(MyApp());
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   // var themePro = Provider.of<ThemePr>(context);
    return MaterialApp(

      debugShowCheckedModeBanner: false,


      home: DataScreen(),
    );
  }
}