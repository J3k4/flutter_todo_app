import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

void main() => runApp(new TodoApp());


class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch: Colors.indigo,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return new MaterialApp(
          title: 'Todo List',
          home: TodoList(),
          theme: theme,
        );
      }
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


  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
  }

  /* can't be saved
  void changeColor() {
    DynamicTheme.of(context).setThemeData(new ThemeData(
        primaryColor: Theme.of(context).primaryColor == Colors.indigo? Colors.red: Colors.indigo
    ));
  }*/


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
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.wb_sunny),
              onPressed: () => changeBrightness()
          ),
          IconButton(

            icon: Icon(Icons.color_lens),
            onPressed: () => {},
            //onPressed: () => changeColor(),
          )
        ],
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
