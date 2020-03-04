import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/pages/storage/home_page.dart';
import 'package:smart_home/pages/storage/search_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static BuildContext _buildContext;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _pageOptions = <Widget>[
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
  static List<Widget> _appBarOptions = [
    AppBar(
      title: Text('IOT'),
    ),
    AppBar(
      title: Text('物品管理'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            BlocProvider.of<StorageSearchBloc>(_buildContext)
                .add(StorageSearchStarted());
            Navigator.push(
              _buildContext,
              MaterialPageRoute(builder: (_) => SearchPage()),
            );
          },
        ),
      ],
    ),
    AppBar(title: Text('留言板')),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    return Scaffold(
      appBar: _appBarOptions.elementAt(_selectedIndex),
      body: Center(
        child: _pageOptions.elementAt(_selectedIndex),
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
            if (index == 1) {
              BlocProvider.of<StorageBloc>(_buildContext).add(StorageStarted());
            }
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
