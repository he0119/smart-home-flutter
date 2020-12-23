import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

typedef Future<List<T>> DropdownSearchOnFind<T>(String text);

class MyDropdownSearch<T> extends StatelessWidget {
  final String label;
  final DropdownSearchOnFind<T> onFind;
  final DropdownSearchItemAsString<T> itemAsString;
  final ValueChanged<T> onChanged;
  final T selectedItem;
  final bool showClearButton;

  const MyDropdownSearch({
    Key key,
    this.label,
    this.onFind,
    this.itemAsString,
    this.onChanged,
    this.selectedItem,
    this.showClearButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      label: label,
      mode: Mode.MENU,
      showSearchBox: true,
      showClearButton: showClearButton,
      dropdownSearchDecoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
      ),
      searchBoxDecoration: InputDecoration(
        labelText: '搜索',
        contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
      ),
      emptyBuilder: (context, searchEntry) => Center(
        child: Text('无结果'),
      ),
      onFind: onFind,
      itemAsString: itemAsString,
      onChanged: onChanged,
      selectedItem: selectedItem,
    );
  }
}
