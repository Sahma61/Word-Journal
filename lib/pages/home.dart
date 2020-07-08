import 'package:Journal/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:Journal/pages/edit_entry.dart';
import 'package:Journal/classes/database.dart';
import 'package:intl/intl.dart'; // Format Dates

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Database _database;
  Future<List<Journal>> _loadJournals() async {
    await DatabaseFileRoutines().readJournals().then((journalsJson) {
      _database = databaseFromJson(journalsJson);
      _database.journal
          .sort((comp1, comp2) => comp2.date.compareTo(comp1.date));
    });
    return _database.journal;
  }

  // Add or Edit Journal Entry and call the Show Entry Dialog
  void _addOrEditJournal({bool add, int index, Journal journal}) async {
    JournalEdit _journalEdit = JournalEdit(action: '', journal: journal);
    _journalEdit = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditEntry(
                add: add,
                index: index,
                journalEdit: _journalEdit,
              ),
          fullscreenDialog: true),
    );

    switch (_journalEdit.action) {
      case 'Save':
        if (add) {
          setState(() {
            _database.journal.add(_journalEdit.journal);
          });
        } else {
          setState(() {
            _database.journal[index] = _journalEdit.journal;
          });
        }
        DatabaseFileRoutines().writeJournals(databaseToJson(_database));
        break;
      case 'Cancel':
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Journal'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder(
        initialData: [],
        future: _loadJournals(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : _buildListViewSeparated(snapshot);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: const EdgeInsets.all(24.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        child: Icon(Icons.add),
        onPressed: () async {
          _addOrEditJournal(add: true, index: -1, journal: Journal());
        },
      ),
      drawer: LeftDrawerWidget(),
    );
  }

  // Build the ListView with Separator
  Widget _buildListViewSeparated(AsyncSnapshot snapshot) {
    return ListView.separated(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        String _subtitle = snapshot.data[index].note;
        String _title = snapshot.data[index].name;
        return Dismissible(
            key: Key(snapshot.data[index].id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: Column(
                children: <Widget>[
                  Text(
                    DateFormat.d()
                        .format(DateTime.parse(snapshot.data[index].date)),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        color: Colors.blue),
                  ),
                  Text(
                    DateFormat.MMM()
                        .format(DateTime.parse(snapshot.data[index].date)),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              title: Text(
                _title,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(
                _subtitle,
                style: TextStyle(color: Colors.black87),
              ),
              onTap: () async {
                _addOrEditJournal(
                  add: false,
                  index: index,
                  journal: snapshot.data[index],
                );
              },
            ),
            confirmDismiss: (direction) async {
              bool isDismissed = await _confirmDeleteJournal();
              if (isDismissed) {
                setState(() {
                  _database.journal.removeAt(index);
                });
                DatabaseFileRoutines().writeJournals(databaseToJson(_database));
              }
            });
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: Colors.grey,
        );
      },
    );
  }

  Future<bool> _confirmDeleteJournal() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                "Do you want to remove this entry?",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              elevation: 48.0,
              actions: <Widget>[
                FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('No'),
                ),
              ]);
        });
  }
}
