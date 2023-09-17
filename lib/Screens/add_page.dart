import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_app/services/todo_service.dart';

import '../utils/snackbar_helper.dart'; 

class AddTodoPage extends StatefulWidget {

  final Map? todo;
  const AddTodoPage({
    // super.key,
    this.todo,
  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEdit = false;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final todo = widget.todo;
    if(todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Todo" : "Add Todo")
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [ 
          TextField(
             controller: titleController,
             decoration: InputDecoration(hintText: "Title"),
          ),
          TextField(
            controller: descriptionController, 
            decoration: InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData, 
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isEdit ? "Update" : "Submit"
              ),
            )
          )
        ],
      )
    ) ;
  }

  // Form Handling (When we click to the "Submit" Button)
  Future<void> submitData() async {
    // Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;

    //-- creating a body
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    // Submit data to the server
    //-- First add the http dart package in the pubspec.yaml file and import the package or library in the file
    final url = "http://api.nstack.in/v1/todos";
    //-- Now convert the URL into URI
    final uri = Uri.parse(url);
    
    final response = await http.post(
      uri, 
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    // show success or fail message based on status
    if(response.statusCode == 201) {
      titleController.text = "";
      descriptionController.text = "";
      showSuccessMessage(context, message: "Creation Success");
    } else { 
      showErrorMessage(context, message: "Creation Failed");
    }
  }

  // Edit data from the form using the same todo item value.
  Future<void> updateData() async {

    final todo = widget.todo;
    if(todo == null) {
      print('You cannot call updated without todo data !!');
      return;
    }
    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptionController.text;

    //-- creating a body
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    
    final isSuccess = await  TodoService.updateTodo(id, body);

    // show success or fail message based on status
    if(isSuccess) {
      showSuccessMessage(context, message: "Data updated Successfully");
    } else { 
      showErrorMessage(context, message: "Updation Failed");
    }

  }
}