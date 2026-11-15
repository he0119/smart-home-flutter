import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/router/router_extensions.dart';

class SearchIconButton extends StatelessWidget {
  const SearchIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '搜索',
      icon: const Icon(Icons.search),
      onPressed: () {
        context.goSearch();
      },
    );
  }
}
