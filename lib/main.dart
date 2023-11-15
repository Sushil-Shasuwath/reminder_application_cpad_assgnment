import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'X1lDXvs8eqh5OgpOiTikewtsSqnyvTAMIekUmTm5';
  final keyClientKey = '3OmQfeYSHBdbbzFkdFzwGY41eR65CZqQBzAfGgP3';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(home: Task()));
}

class Task extends StatefulWidget {
  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void saveContent() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task details cannot be empty!"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveContentToParse(titleController.text, contentController.text);
    setState(() {
      titleController.clear();
      contentController.clear();
    });
  }

  void clearContent() {
    setState(() {
      titleController.clear();
      contentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = new DateFormat('MMM dd,\nyyyy\nhh:mm');
    final originalDateFormat = new DateFormat('MMM dd, yyyy hh:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo Application - CPAD Assignment"),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      focusNode: null,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      cursorColor: Colors.greenAccent,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleController,
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.black12),
                          ),
                          labelText: "ToDo Header",
                          labelStyle: TextStyle(color: Colors.greenAccent)),
                    ),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      focusNode: null,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      cursorColor: Colors.greenAccent,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                      controller: contentController,
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.black12),
                          ),
                          labelText: "ToDo Content",
                          labelStyle: TextStyle(color: Colors.greenAccent)),
                    ),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 0.0),
              child: Row(children: <Widget>[
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 153, 187, 115),
                      minimumSize: Size(142, 40),
                    ),
                    onPressed: clearContent,
                    child: Text("Clear")),
                SizedBox(width: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.greenAccent,
                      minimumSize: Size(242, 40),
                    ),
                    onPressed: saveContent,
                    child: Text("Save")),
              ])),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTask(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.greenAccent),
                              )),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTask = snapshot.data![index];
                                final varTitle = varTask.get<String>('title')!;
                                final varContent =
                                    varTask.get<String>('content')!;
                                final varStatus = varTask.get<bool>('status')!;
                                final varDate = dateFormat.format(
                                    varTask.get<DateTime>('updatedAt')!);
                                final varOriginalDate =
                                    originalDateFormat.format(
                                        varTask.get<DateTime>('updatedAt')!);
                                //*************************************

                                return ListTile(
                                  title: Text(varTitle),
                                  subtitle: Text(varContent),
                                  isThreeLine: true,
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TaskDetails(
                                              varTitle,
                                              varContent,
                                              varOriginalDate,
                                              varStatus))),
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 153, 187, 115),
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(4.0),
                                          bottomRight: Radius.circular(4.0),
                                          topLeft: Radius.circular(4.0),
                                          bottomLeft: Radius.circular(4.0)),
                                    ),
                                    padding:
                                        EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                                    child: Text(
                                      varDate,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                          value: varStatus,
                                          activeColor: Colors.greenAccent,
                                          onChanged: (value) async {
                                            await updateTask(
                                                varTask.objectId!, value!);
                                            setState(() {
                                              //Refresh UI
                                            });
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.greenAccent,
                                        ),
                                        onPressed: () async {
                                          await deleteTask(varTask.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text(
                                                  "Task Deleted Successfully!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }

  Future<void> saveContentToParse(String title, String content) async {
    final todo = ParseObject('ToDoFlutter')
      ..set('title', title)
      ..set('content', content)
      ..set('status', false);
    await todo.save();
  }

  Future<List<ParseObject>> getTask() async {
    QueryBuilder<ParseObject> queryTask =
        QueryBuilder<ParseObject>(ParseObject('ToDoFlutter'));
    final ParseResponse apiResponse = await queryTask.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTask(String id, bool status) async {
    var todo = ParseObject('ToDoFlutter')
      ..objectId = id
      ..set('status', status);
    await todo.save();
  }

  Future<void> deleteTask(String id) async {
    var todo = ParseObject('ToDoFlutter')..objectId = id;
    await todo.delete();
  }
}

class TaskDetails extends StatefulWidget {
  final String varTitle;
  final String varContent;
  final String varOriginalDate;
  final bool varStatus;

  TaskDetails(
      this.varTitle, this.varContent, this.varOriginalDate, this.varStatus);

  @override
  _TaskDetailsState createState() =>
      _TaskDetailsState(varTitle, varContent, varOriginalDate, varStatus);
}

class _TaskDetailsState extends State<TaskDetails> {
  final String varTitle;
  final String varContent;
  final String varOriginalDate;
  final bool varStatus;

  _TaskDetailsState(
      this.varTitle, this.varContent, this.varOriginalDate, this.varStatus);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Task Details"),
          backgroundColor: Colors.greenAccent,
          centerTitle: true,
        ),
        body: Container(
            padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
            child: Column(children: <Widget>[
              Column(
                children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
                      child: Text(
                        varTitle,
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 1.0),
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
                      width: 500,
                      child: Text(varContent)),
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
                      width: 500,
                      child: Text(
                        varOriginalDate,
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
                      width: 500,
                      child: Text(
                        varStatus ? "Status: DONE" : "Status: Pending",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ))
                ],
              ),
            ])));
  }
}
