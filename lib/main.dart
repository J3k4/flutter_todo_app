import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new TodoApp());


class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Todo List',
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<String> _todoItems = [];

  // called on AppStart
  @override
  void initState(){
    super.initState();
    _loadTodoItems();
  }

  // load the saved Item List
  _loadTodoItems() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _todoItems = (prefs.getStringList('todoList') ?? []);
    });
  }

  // safe the Item List
  _saveTodoItems() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todoList', _todoItems);
  }

  // add an item to list
  void _addTodoItem(String task) {
    if(task.length > 0) {
      _todoItems.add(task);
      _saveTodoItems();
    }
  }

  // remove an item from list
  void _removeTodoItem(int index){
    setState(() {
      _todoItems.removeAt(index);
      _saveTodoItems();
    });
  }

  // push a new page with TextField to add a new task
  void _pushAddTodoScreen(){
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context){
            return new Scaffold(
              appBar: AppBar(title: Text('Add a new task')),
              body: TextField(
                autofocus: true,
                onSubmitted: (val){
                  _addTodoItem(val);
                  Navigator.pop(context);
                },
                decoration: InputDecoration(
                  hintText: 'Enter something to do...',
                  contentPadding: const EdgeInsets.all(16.0)
                ),
              ),
            );
      })
    );
  }

  // ask in an AlertWidget to remove a task
  void _promptRemoveTodoItem(int index){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark "${_todoItems[index]}" as done?'),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('CANCLE')
            ),
            FlatButton(
                onPressed: (){
                  _removeTodoItem(index);
                  Navigator.of(context).pop();
                },
                child: Text('MARK AS DONE')
            )
          ],
        );
      }
    );
  }


  Widget _buildTodoItem(String todoText, int index){
    return ListTile(
      title: new Text(todoText),
      onTap: () => _promptRemoveTodoItem(index),
    );
  }


  Widget _buildTodoList(){
    return new ListView.builder(
        itemBuilder: (context, index) {
          if(index < _todoItems.length) {
            return _buildTodoItem(_todoItems[index], index);
          }
        },
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: 'Add atsk',
        child: Icon(Icons.add),
      ),
    );
  }
}
