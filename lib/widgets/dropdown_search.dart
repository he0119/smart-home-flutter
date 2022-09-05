import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

typedef DropdownSearchOnFind<T> = Future<List<T>> Function(String? text);

class MyDropdownSearch<T> extends StatelessWidget {
  final String? label;
  final DropdownSearchOnFind<T>? asyncItems;
  final ValueChanged<T?>? onChanged;
  final T? selectedItem;
  final bool showClearButton;
  final String? Function(T?)? validator;
  final AutovalidateMode autoValidateMode;

  const MyDropdownSearch({
    Key? key,
    this.label,
    this.asyncItems,
    this.onChanged,
    this.selectedItem,
    this.showClearButton = false,
    this.validator,
    this.autoValidateMode = AutovalidateMode.disabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      compareFn: (i1, i2) => i1 == i2,
      popupProps: PopupProps.menu(
        showSelectedItems: true,
        showSearchBox: true,
        itemBuilder: (ctx, item, isSelected) {
          return ListTile(
            title: Text(item.toString()),
            selected: isSelected,
          );
        },
        emptyBuilder: (context, searchEntry) => const Center(
          child: Text('无结果'),
        ),
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            labelText: '搜索',
            contentPadding: EdgeInsets.fromLTRB(8, 0, 0, 0),
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          labelText: label,
        ),
      ),
      clearButtonProps: const ClearButtonProps(isVisible: true),
      asyncItems: asyncItems,
      onChanged: onChanged,
      selectedItem: selectedItem,
      validator: validator,
      autoValidateMode: autoValidateMode,
    );
  }
}
