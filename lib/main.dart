import 'package:flutter/material.dart';

import 'my_home_page.dart';

void main() {
  // Link Chaleno (https://pub.dev/packages/chaleno)
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.indigo[900]!,
      ),
      home: MyHomePage(),
    );
  }
}
