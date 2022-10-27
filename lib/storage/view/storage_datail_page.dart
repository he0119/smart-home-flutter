import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/storage.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';
import 'package:smarthome/storage/view/storage_edit_page.dart';
import 'package:smarthome/storage/view/widgets/add_storage_icon_button.dart';
import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/storage/view/widgets/storage_item_list.dart';
import 'package:smarthome/utils/constants.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';
import 'package:smarthome/widgets/home_page.dart';

class StorageDetailPage extends Page {
  final String storageId;

  StorageDetailPage({
    required this.storageId,
  }) : super(
          key: UniqueKey(),
          name: '/storage/$storageId',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<StorageDetailBloc>(
            create: (context) => StorageDetailBloc(
              storageRepository: context.read<StorageRepository>(),
            )..add(StorageDetailFetched(id: storageId)),
          ),
          BlocProvider<StorageEditBloc>(
            create: (context) => StorageEditBloc(
              storageRepository: context.read<StorageRepository>(),
            ),
          )
        ],
        child: StorageDetailScreen(
          storageId: storageId,
        ),
      ),
    );
  }
}

class StorageDetailScreen extends StatelessWidget {
  final String storageId;

  const StorageDetailScreen({
    Key? key,
    required this.storageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageDetailBloc, StorageDetailState>(
      builder: (context, state) {
        final paths = state.storage.ancestors ?? [];
        if (!paths.contains(state.storage) &&
            state.storage.id != homeStorage.id) {
          // 防止重复添加相同名称的位置
          // 因为无限列表重新获取时，位置对象虽然名字不会变，但是内容改变
          if (paths.isEmpty || paths.last.name != state.storage.name) {
            paths.add(state.storage);
          }
        }
        return MySliverPage(
          title: state.storage.name,
          onRefresh: () async {
            if (state.status == StorageDetailStatus.success) {
              context.read<StorageDetailBloc>().add(
                    StorageDetailFetched(
                      id: state.storage.id,
                      cache: false,
                    ),
                  );
            } else {
              context.read<StorageDetailBloc>().add(
                    StorageDetailFetched(
                      id: storageId,
                      cache: false,
                    ),
                  );
            }
          },
          actions: <Widget>[
            AddStorageIconButton(
              storage: state.storage,
            ),
            const SearchIconButton(),
            if (state.storage.id != homeStorage.id)
              PopupMenuButton<Menu>(
                onSelected: (value) async {
                  if (value == Menu.edit) {
                    final storageDetailBloc = context.read<StorageDetailBloc>();

                    final r = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<StorageEditBloc>(
                          create: (_) => StorageEditBloc(
                            storageRepository:
                                context.read<StorageRepository>(),
                          ),
                          child: StorageEditPage(
                            isEditing: true,
                            storage: state.storage,
                          ),
                        ),
                      ),
                    );
                    if (r == true) {
                      storageDetailBloc.add(
                        StorageDetailFetched(id: storageId, cache: false),
                      );
                    }
                  }
                  if (value == Menu.delete) {
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
                              context.read<StorageEditBloc>().add(
                                    StorageDeleted(storage: state.storage),
                                  );
                              Navigator.of(context).pop();
                            },
                            child: const Text('是'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: Menu.edit,
                    child: Text('编辑'),
                  ),
                  const PopupMenuItem(
                    value: Menu.delete,
                    child: Text('删除'),
                  ),
                ],
              )
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
                  context.read<StorageDetailBloc>().add(
                        StorageDetailFetched(id: storageId),
                      );
                },
                message: state.error,
              ),
            if (state.status == StorageDetailStatus.loading)
              const SliverCenterLoadingIndicator(),
            if (state.status == StorageDetailStatus.success)
              StorageItemList(
                items: state.storage.items!.toList(),
                storages: state.storage.children!.toList(),
                hasReachedMax: state.hasReachedMax,
                onFetch: () => context.read<StorageDetailBloc>().add(
                      StorageDetailFetched(
                        id: state.storage.id,
                      ),
                    ),
              )
          ],
          floatingActionButton: FloatingActionButton(
            tooltip: '添加物品',
            onPressed: () async {
              final storageDetailBloc = context.read<StorageDetailBloc>();

              final r = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<ItemEditBloc>(
                    create: (_) => ItemEditBloc(
                      storageRepository: context.read<StorageRepository>(),
                    ),
                    child: ItemEditPage(
                      isEditing: false,
                      storage: state.storage,
                    ),
                  ),
                ),
              );
              if (r == true) {
                storageDetailBloc.add(
                  StorageDetailFetched(id: storageId, cache: false),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class PathBarDelegate extends SliverPersistentHeaderDelegate {
  final List<Storage> paths;

  const PathBarDelegate({required this.paths});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                    MyRouterDelegate.of(context).setStoragePage();
                  },
                )
              : InkWell(
                  onTap: () {
                    // 单击当前位置的时候，不做任何转跳
                    // 禁止原地 TP
                    if (index != paths.length) {
                      MyRouterDelegate.of(context)
                          .setStoragePage(storage: paths[index - 1]);
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
          return const Icon(
            Icons.arrow_forward_ios,
            size: 12,
          );
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
