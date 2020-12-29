import 'package:flutter/material.dart';
import 'package:smart_home/pages/storage/search_page.dart';
import 'package:smart_home/routers/delegate.dart';

class SearchIconButton extends StatelessWidget {
  const SearchIconButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '搜索',
      child: IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          MyRouterDelegate.of(context).push(SearchPage());
        },
      ),
    );
  }
}
