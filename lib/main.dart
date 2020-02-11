import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  var archives = new List<Item>();

  HomePage() {
    archives = [];

    items = [];

    // items.add(Item(title: "Socar o fera as 9:10hr", done: false));
    // items.add(Item(title: "Falar mão dos esquerdistas", done: true));
    // items.add(Item(title: "Dar voadora do Paloma", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add() {
    if (newTaskCtrl.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text, done: false));
      newTaskCtrl.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  void archive(int index) {
    final item = widget.items[index];

    setState(() {
      widget.archives.add(item);
      widget.items.removeAt(index);
      saveToArchive();
    });
  }

  Future loadStorage() async {
    var prefs = await SharedPreferences.getInstance();
    var items = prefs.getString('items');
    print(items);
    /**
     * Task Items
     */
    if (items != null) {
      Iterable decoded = jsonDecode(items);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
    /**
     * Archives
     */
    var archives = prefs.getString('archives');
    if (archives != null) {
      Iterable decoded = jsonDecode(archives);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.archives = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('items', jsonEncode(widget.items));
  }

  saveToArchive() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('archives', jsonEncode(widget.archives));
  }

  _HomePageState() {
    loadStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 10),
            child: Align(
              alignment: Alignment.center,
              child: Text("Arquivo: ${widget.archives.length.toString()}"),
            ),
          )
        ],
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctx, int index) {
          final item = widget.items[index];

          return Dismissible(
            key: Key("${index.toString()}-${item.title}"),
            background: Container(
              padding: EdgeInsets.only(left: 20),
              color: Colors.yellow.withOpacity(0.9),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.archive,
                  color: Colors.grey[500],
                ),
              ),
            ),
            secondaryBackground: Container(
              padding: EdgeInsets.only(right: 20),
              color: Colors.red.withOpacity(0.6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.delete,
                  color: Colors.grey[100],
                ),
              ),
            ),
            onDismissed: (dir) {
              String action;
              if (dir == DismissDirection.endToStart) {
                action = "removida";
                remove(index);
              } else {
                action = "arquivada";
                archive(index);
              }

              Scaffold.of(ctx).showSnackBar(
                SnackBar(
                  content: Text("Tarefa foi $action com sucesso"),
                  backgroundColor: action == "removida" ? Colors.green : Colors.yellow[600],
                ),
              );
            },
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              activeColor: Colors.lightBlueAccent,
              checkColor: Colors.white,
              secondary: Icon(Icons.announcement),
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.playlist_add),
        backgroundColor: Colors.blue[400],
      ),
    );
  }
}
