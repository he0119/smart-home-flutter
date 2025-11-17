import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/providers/storage_detail_provider.dart';
import 'package:smarthome/storage/view/storage_edit_page.dart';

class AddStorageIconButton extends ConsumerWidget {
  final Storage? storage;

  const AddStorageIconButton({super.key, this.storage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: '添加位置',
      child: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () async {
          final r = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  StorageEditPage(isEditing: false, storage: storage),
            ),
          );
          if (r == true) {
            ref.read(storageDetailProvider.notifier).refresh();
          }
        },
      ),
    );
  }
}
