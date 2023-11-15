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

  runApp(MaterialApp(home: Note()));
}

class Note extends StatefulWidget {
  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void saveContent() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Note details cannot be empty!"),
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
        title: Text("Reminder Application - CPAD Assignment"),
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
                          labelText: "Title",
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
                          labelText: "Notes",
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
                      backgroundColor: Colors.greenAccent,
                      minimumSize: Size(142, 40),
                      // minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: saveContent,
                    child: Text("Save")),
                SizedBox(width: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 153, 187, 115),
                      minimumSize: Size(142, 40),
                      // minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: clearContent,
                    child: Text("Clear")),
              ])),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getNote(),
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
                              padding:
                                  EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
                              // padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final varNote = snapshot.data![index];
                                final varTitle = varNote.get<String>('title')!;
                                final varContent =
                                    varNote.get<String>('content')!;
                                final varStatus = varNote.get<bool>('status')!;
                                final varDate = dateFormat.format(
                                    varNote.get<DateTime>('updatedAt')!);
                                final varOriginalDate =
                                    originalDateFormat.format(
                                        varNote.get<DateTime>('updatedAt')!);

                                return ListTile(
                                  title: new Center(
                                      child: new Text(varTitle,
                                          style: new TextStyle())),
                                  subtitle: new Center(
                                      child: new Text(varContent,
                                          style: new TextStyle())),
                                  isThreeLine: true,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black12, width: 2)),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => NoteDetails(
                                              varTitle,
                                              varContent,
                                              varOriginalDate,
                                              varStatus))),
                                  leading: Container(
                                    width: 60.0,
                                    height: 50.0,
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
                                        fontSize: 12,
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
                                            await updateNote(
                                                varNote.objectId!, value!);
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
                                          await deleteNote(varNote.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text(
                                                  "Note Deleted Successfully!"),
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
    final reminder = ParseObject('ReminderFlutter')
      ..set('title', title)
      ..set('content', content)
      ..set('status', false);
    await reminder.save();
  }

  Future<List<ParseObject>> getNote() async {
    QueryBuilder<ParseObject> queryNote =
        QueryBuilder<ParseObject>(ParseObject('ReminderFlutter'));
    final ParseResponse apiResponse = await queryNote.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateNote(String id, bool status) async {
    var reminder = ParseObject('ReminderFlutter')
      ..objectId = id
      ..set('status', status);
    await reminder.save();
  }

  Future<void> deleteNote(String id) async {
    var reminder = ParseObject('ReminderFlutter')..objectId = id;
    await reminder.delete();
  }
}

class NoteDetails extends StatefulWidget {
  final String varTitle;
  final String varContent;
  final String varOriginalDate;
  final bool varStatus;

  NoteDetails(
      this.varTitle, this.varContent, this.varOriginalDate, this.varStatus);

  @override
  _NoteDetailsState createState() =>
      _NoteDetailsState(varTitle, varContent, varOriginalDate, varStatus);
}

class _NoteDetailsState extends State<NoteDetails> {
  final String varTitle;
  final String varContent;
  final String varOriginalDate;
  final bool varStatus;

  _NoteDetailsState(
      this.varTitle, this.varContent, this.varOriginalDate, this.varStatus);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Reminders"),
          backgroundColor: Colors.greenAccent,
          centerTitle: true,
        ),
        body: Container(
          width: 500,
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black12,
              width: 2,
            ),
          ),
          padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
          margin: EdgeInsets.symmetric(vertical: 70.0, horizontal: 550.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Title : ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.greenAccent)),
                    Text(varTitle)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Notes : ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.greenAccent)),
                    Text(varContent)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date : ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.greenAccent)),
                    Text(varOriginalDate)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Status : ",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.greenAccent)),
                    Text(varStatus ? "DONE" : "Pending")
                  ],
                ),
              ),
            ],
          ),
        ));
    // Container(
    //         padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
    //         child: Column(children: <Widget>[
    //           Column(
    //             children: [
    //               Container(
    //                   padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
    //                   child: Text(varTitle,
    //                       // style: DefaultTextStyle.of(context)
    //                       //     .style
    //                       //     .apply(fontSizeFactor: 1.0),
    //                       style: TextStyle(
    //                           color: Colors.greenAccent,
    //                           fontWeight: FontWeight.w600))),
    //               Container(
    //                   padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
    //                   width: 500,
    //                   child: Text(varContent)),
    //               Container(
    //                   padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
    //                   width: 500,
    //                   child: Text(
    //                     varOriginalDate,
    //                   )),
    //               Container(
    //                   padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 18.0),
    //                   width: 500,
    //                   child: Text(
    //                     varStatus ? "Status: DONE" : "Status: Pending",
    //                     style: TextStyle(color: Colors.black),
    //                   ))
    //             ],
    //           ),
    //         ])));
  }
}
