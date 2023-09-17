import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_app/Screens/add_page.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_app/services/todo_service.dart';

import '../utils/snackbar_helper.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {

  bool isLoading = false;
  List items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"), 
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo, 
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                "No Todo Item",
                style: Theme.of(context).textTheme.headline5,
              )
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
          
                final item = items[index];
                final id = item['_id'];
          
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text("${index + 1}")),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if(value == "edit") {
                          // show edit page
                          NavigateToEditPage(item);
                        } else if(value == "delete") {
                          // Delete and remove the item
                          deleteById(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Text("Edit"),
                            value: "edit"
                          ),
                          PopupMenuItem(
                            child: Text("Delete"),
                            value: "delete"
                          )
                        ];
                      }
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: NavigateToAddPage, 
        label: Text("Add Todo")
      ),
    );
  }

  // Edit the data using the existing form so pass it to the Edit Page
  Future<void> NavigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  // When Tap to "Add Todo" button, it will navigate to add_todo page
  Future<void> NavigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage()
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  // Get the data from the URL
  Future<void> fetchTodo() async {
    
    final response = await TodoService.fetchTodo();

    if(response != null){
      // print(result);
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage(context, message: "Something went wrong !!");
    }

    setState(() {
      isLoading = false;
    });
  }

  // Delete the item using ID
  Future<void> deleteById(String id) async {
    // Delete the item
    final isSuccess = await TodoService.deleteById(id);
    if(isSuccess == 200){
    // Remove item from the list
    final dataItem = items.where((element) => element['_id'] != id).toList();
    setState(() {
      items = dataItem;
    });
    } else {
      // Show error
      showErrorMessage(context, message: "Deletion Failed !!");
    }

  }

}