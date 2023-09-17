import 'package:flutter/material.dart';
import 'Screens/todo_list.dart';

void main() {
  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false ,
      theme: ThemeData.dark(),
      home: TodoListPage(),
    );
  }
}