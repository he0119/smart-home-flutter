import 'package:flutter/material.dart';
import 'package:smarthome/core/router/router_extensions.dart';

class SearchIconButton extends StatelessWidget {
  const SearchIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '搜索',
      child: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          context.goSearch();
        },
      ),
    );
  }
}
