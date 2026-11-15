import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/providers/storage_detail_provider.dart';
import 'package:smarthome/storage/view/storage_edit_page.dart';

class AddStorageIconButton extends ConsumerWidget {
  final Storage? storage;

  const AddStorageIconButton({super.key, this.storage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // IconButton.tooltip 自带悬停提示和语义标签，外面再包 Tooltip 会念两遍
    return IconButton(
      tooltip: '添加位置',
      icon: const Icon(Icons.create_new_folder_outlined),
      onPressed: () async {
        final r = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StorageEditPage(isEditing: false, storage: storage),
          ),
        );
        if (r == true && storage != null) {
          ref.read(storageDetailProvider(storage!.id).notifier).refresh();
        }
      },
    );
  }
}
