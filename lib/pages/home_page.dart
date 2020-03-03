import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/blocs.dart';
import 'package:smart_home/pages/search_page.dart';
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
      'Index 0: 主页',
      style: optionStyle,
    ),
    StorageHomePage(),
    SearchPage(),
  ];
  StorageSearchBloc _storageSearchBloc;
  StorageBloc _storageBloc;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    _storageSearchBloc = BlocProvider.of<StorageSearchBloc>(context);
    _storageBloc = BlocProvider.of<StorageBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('智慧家庭'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('主页'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            title: Text('物品'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('搜索'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _storageBloc.add(StorageRoot());
    }
    if (index == 2) {
      _storageSearchBloc.add(StorageSearchChanged(''));
    }
    setState(() {
      _selectedIndex = index;
    });
  }
}
