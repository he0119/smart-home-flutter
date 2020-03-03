import 'package:flutter/material.dart';
import 'package:smart_home/pages/storage/home_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: IOT',
      style: optionStyle,
    ),
    StorageHomePage(),
    Text(
      'Index 2: 留言板',
      style: optionStyle,
    ),
  ];
  static List<String> _titles = ['IOT', '物品管理', '留言板'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles.elementAt(_selectedIndex)),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.cloud), title: Text('IOT')),
          BottomNavigationBarItem(icon: Icon(Icons.storage), title: Text('物品')),
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text('留言板')),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
