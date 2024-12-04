import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class MyDropdownSearch<T> extends StatelessWidget {
  final String? label;
  final DropdownSearchOnFind<T>? items;
  final ValueChanged<T?>? onChanged;
  final T? selectedItem;
  final bool showClearButton;
  final String? Function(T?)? validator;
  final AutovalidateMode autoValidateMode;

  const MyDropdownSearch({
    super.key,
    this.label,
    this.items,
    this.onChanged,
    this.selectedItem,
    this.showClearButton = false,
    this.validator,
    this.autoValidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      compareFn: (i1, i2) => i1 == i2,
      popupProps: PopupProps.menu(
        disableFilter: true,
        showSelectedItems: true,
        showSearchBox: true,
        itemBuilder:
            (BuildContext context, T item, bool isDisabled, bool isSelected) {
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
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          labelText: label,
        ),
      ),
      suffixProps: DropdownSuffixProps(
        clearButtonProps: const ClearButtonProps(isVisible: true),
      ),
      items: items,
      onChanged: onChanged,
      selectedItem: selectedItem,
      validator: validator,
      autoValidateMode: autoValidateMode,
    );
  }
}
