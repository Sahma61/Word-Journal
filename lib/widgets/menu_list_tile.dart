import 'package:flutter/material.dart';

class MenuListTileWidget extends StatefulWidget {
  @override
  _MenuListTileWidgetState createState() => _MenuListTileWidgetState();
}

class _MenuListTileWidgetState extends State<MenuListTileWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.cake
            ),
            title: Text('Bithdays'),
            onTap: null,
        ),
        ListTile(
          leading: Icon(
            Icons.sentiment_satisfied
          ),
          title: Text('Gratitude'),
        ),
        ListTile(
          leading: Icon(
            Icons.alarm
            ),
            title: Text('Reminders'),
        ),
        Divider(color: Colors.grey),
        ListTile(),
      ],
    );
  }
}