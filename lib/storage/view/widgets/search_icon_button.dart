import 'package:flutter/material.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/view/search_page.dart';

class SearchIconButton extends StatelessWidget {
  const SearchIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '搜索',
      child: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          MyRouterDelegate.of(context).push(SearchPage());
        },
      ),
    );
  }
}
