import 'package:flutter/material.dart';
import 'package:smart_home/widgets/search_form.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('物品搜索'),
      ),
      body: SearchForm(),
    );
  }
}
