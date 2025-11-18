import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/storage/model/popup_menu.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';
import 'package:smarthome/storage/view/storage_edit_page.dart';
import 'package:smarthome/storage/view/storage_qr_page.dart';
import 'package:smarthome/storage/view/widgets/add_storage_icon_button.dart';
import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/storage/view/widgets/storage_item_list.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';

class StorageDetailPage extends StatelessWidget {
  final String storageId;

  const StorageDetailPage({super.key, required this.storageId});

  @override
  Widget build(BuildContext context) {
    return StorageDetailScreen(storageId: storageId);
  }
}

class StorageDetailScreen extends ConsumerStatefulWidget {
  final String storageId;

  const StorageDetailScreen({super.key, required this.storageId});

  @override
  ConsumerState<StorageDetailScreen> createState() =>
      _StorageDetailScreenState();
}

class _StorageDetailScreenState extends ConsumerState<StorageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storageDetailProvider(widget.storageId));

    // Listen to storage edit state for delete notifications
    ref.listen<StorageEditState>(storageEditProvider, (previous, next) {
      if (next.status == StorageEditStatus.deleteSuccess) {
        showInfoSnackBar('位置 ${next.storage?.name ?? ''} 删除成功');
        Navigator.of(context).pop();
      }
      if (next.status == StorageEditStatus.failure) {
        showErrorSnackBar(next.errorMessage);
      }
    });
    final paths = state.storage.ancestors ?? [];
    if (!paths.contains(state.storage) && state.storage.id != homeStorage.id) {
      // 防止重复添加相同名称的位置
      // 因为无限列表重新获取时，位置对象虽然名字不会变，但是内容改变
      if (paths.isEmpty || paths.last.name != state.storage.name) {
        paths.add(state.storage);
      }
    }
    return MySliverScaffold(
      title: Text(state.storage.name),
      onRefresh: () async {
        ref.read(storageDetailProvider(widget.storageId).notifier).refresh();
      },
      actions: <Widget>[
        AddStorageIconButton(storage: state.storage),
        const SearchIconButton(),
        if (state.storage.id != homeStorage.id)
          PopupMenuButton<StorageDetailMenu>(
            onSelected: (value) async {
              final navigator = Navigator.of(context);

              if (value == StorageDetailMenu.edit) {
                final r = await navigator.push(
                  MaterialPageRoute(
                    builder: (_) => StorageEditPage(
                      isEditing: true,
                      storage: state.storage,
                    ),
                  ),
                );
                if (r == true) {
                  ref
                      .read(storageDetailProvider(widget.storageId).notifier)
                      .refresh();
                }
              }
              if (value == StorageDetailMenu.delete) {
                if (context.mounted) {
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('删除 ${state.storage.name}'),
                      content: const Text('你确认要删除该位置么？'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('否'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(storageEditProvider.notifier)
                                .deleteStorage(state.storage);
                            Navigator.of(context).pop();
                          },
                          child: const Text('是'),
                        ),
                      ],
                    ),
                  );
                }
              }
              if (value == StorageDetailMenu.qr) {
                await navigator.push(
                  MaterialPageRoute(
                    builder: (_) => StorageQRPage(storage: state.storage),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: StorageDetailMenu.edit,
                child: Text('编辑'),
              ),
              const PopupMenuItem(
                value: StorageDetailMenu.delete,
                child: Text('删除'),
              ),
              const PopupMenuItem(
                value: StorageDetailMenu.qr,
                child: Text('二维码'),
              ),
            ],
          ),
      ],
      slivers: [
        if (paths.isNotEmpty)
          SliverPersistentHeader(
            pinned: true,
            delegate: PathBarDelegate(paths: paths),
          ),
        if (state.status == StorageDetailStatus.failure)
          SliverErrorMessageButton(
            onPressed: () {
              ref
                  .read(storageDetailProvider(widget.storageId).notifier)
                  .refresh();
            },
            message: state.errorMessage,
          ),
        if (state.status == StorageDetailStatus.loading)
          const SliverCenterLoadingIndicator(),
        if (state.status == StorageDetailStatus.success)
          StorageItemList(
            items: state.storage.items!.toList(),
            storages: state.storage.children!.toList(),
            hasReachedMax: state.hasReachedMax,
            onFetch: () => ref
                .read(storageDetailProvider(widget.storageId).notifier)
                .fetchMore(),
          ),
      ],
      floatingActionButton: FloatingActionButton(
        tooltip: '添加物品',
        onPressed: () async {
          final r = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ItemEditPage(isEditing: false, storage: state.storage),
            ),
          );
          if (r == true) {
            ref
                .read(storageDetailProvider(widget.storageId).notifier)
                .refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PathBarDelegate extends SliverPersistentHeaderDelegate {
  final List<Storage> paths;

  const PathBarDelegate({required this.paths});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: paths.length + 1,
        itemBuilder: (BuildContext context, int index) {
          return index == 0
              ? IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    context.setStoragePage();
                  },
                )
              : InkWell(
                  onTap: () {
                    // 单击当前位置的时候，不做任何转跳
                    // 禁止原地 TP
                    if (index != paths.length) {
                      context.setStoragePageWithStorage(paths[index - 1].id);
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        paths[index - 1].name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Icon(Icons.arrow_forward_ios, size: 12);
        },
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant PathBarDelegate oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
