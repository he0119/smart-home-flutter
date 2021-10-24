import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/storage/view/item_edit_page.dart';
import 'package:smarthome/storage/view/storage_edit_page.dart';
import 'package:smarthome/storage/view/widgets/add_storage_icon_button.dart';
import 'package:smarthome/storage/view/widgets/search_icon_button.dart';
import 'package:smarthome/storage/view/widgets/storage_item_list.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';

class StorageDetailPage extends Page {
  final String storageName;
  final String? storageId;
  final int group;

  StorageDetailPage({
    required this.storageName,
    this.storageId,
    required this.group,
  }) : super(
          key: ValueKey('$group/$storageName'),
          name: '/storage/$group/$storageName',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<StorageDetailBloc>(
            create: (context) => StorageDetailBloc(
              storageRepository:
                  RepositoryProvider.of<StorageRepository>(context),
            )..add(StorageDetailFetched(name: storageName, id: storageId)),
          ),
          BlocProvider<StorageEditBloc>(
            create: (context) => StorageEditBloc(
              storageRepository:
                  RepositoryProvider.of<StorageRepository>(context),
            ),
          )
        ],
        child: StorageDetailScreen(
          storageName: storageName,
          storageId: storageId,
        ),
      ),
    );
  }
}

class StorageDetailScreen extends StatelessWidget {
  final String storageName;
  final String? storageId;

  const StorageDetailScreen({
    Key? key,
    required this.storageName,
    required this.storageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageDetailBloc, StorageDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: RefreshIndicator(
            onRefresh: () async {
              if (state is StorageDetailSuccess) {
                BlocProvider.of<StorageDetailBloc>(context).add(
                  StorageDetailFetched(
                    name: state.storage?.name ?? '',
                    id: state.storage?.id,
                    cache: false,
                  ),
                );
              } else {
                BlocProvider.of<StorageDetailBloc>(context).add(
                  StorageDetailFetched(
                    name: storageName,
                    id: storageId,
                    cache: false,
                  ),
                );
              }
            },
            child: BlocListener<StorageEditBloc, StorageEditState>(
              listener: (context, state) {
                if (state is StorageDeleteSuccess) {
                  showInfoSnackBar('位置 ${state.storage.name} 删除成功');
                  Navigator.pop(context);
                }
                if (state is StorageEditFailure) {
                  showErrorSnackBar(state.message);
                }
              },
              child: _buildBody(context, state),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context, state),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, StorageDetailState state) {
    if (state is StorageDetailSuccess && state.storages != null) {
      return AppBar(
        title: const Text('家'),
        actions: const <Widget>[
          AddStorageIconButton(),
          SearchIconButton(),
        ],
      );
    }
    if (state is StorageDetailSuccess && state.storage != null) {
      final paths = state.storage!.ancestors ?? [];
      if (!paths.contains(state.storage)) {
        // 防止重复添加相同名称的位置
        // 因为无限列表重新获取时，位置对象虽然名字不会变，但是内容改变
        if (paths.isEmpty || paths.last.name != state.storage!.name) {
          paths.add(state.storage!);
        }
      }
      return AppBar(
        title: Text(state.storage!.name),
        actions: <Widget>[
          AddStorageIconButton(
            storage: state.storage,
          ),
          const SearchIconButton(),
          PopupMenuButton<Menu>(
            onSelected: (value) async {
              if (value == Menu.edit) {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider<StorageEditBloc>(
                    create: (_) => StorageEditBloc(
                      storageRepository:
                          RepositoryProvider.of<StorageRepository>(context),
                    ),
                    child: StorageEditPage(
                      isEditing: true,
                      storage: state.storage,
                    ),
                  ),
                ));
              }
              if (value == Menu.delete) {
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('删除 ${state.storage!.name}'),
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
                          BlocProvider.of<StorageEditBloc>(context).add(
                            StorageDeleted(storage: state.storage!),
                          );
                          Navigator.pop(context);
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
        bottom: PathBar(
          child: SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
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
                            MyRouterDelegate.of(context)
                                .setStoragePage(storage: paths[index - 1]);
                          },
                          child: SizedBox(
                            height: 40,
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  paths[index - 1].name,
                                  style: const TextStyle(fontSize: 16),
                                ),
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
            ),
          ),
        ),
      );
    }
    return AppBar(
      title: Text(storageName != '' ? storageName : '家'),
    );
  }

  Widget _buildBody(BuildContext context, StorageDetailState state) {
    if (state is StorageDetailFailure) {
      return ErrorMessageButton(
        onPressed: () {
          BlocProvider.of<StorageDetailBloc>(context).add(
            StorageDetailFetched(name: state.name, id: state.id),
          );
        },
        message: state.message,
      );
    }
    if (state is StorageDetailSuccess && state.storages != null) {
      return StorageItemList(
        storages: state.storages!.toList(),
        items: const [],
        hasReachedMax: state.hasReachedMax,
        onFetch: () => BlocProvider.of<StorageDetailBloc>(context).add(
          const StorageDetailFetched(name: ''),
        ),
      );
    }
    if (state is StorageDetailSuccess && state.storage != null) {
      return StorageItemList(
        items: state.storage!.items!.toList(),
        storages: state.storage!.children!.toList(),
        hasReachedMax: state.hasReachedMax,
        onFetch: () => BlocProvider.of<StorageDetailBloc>(context).add(
          StorageDetailFetched(
            name: state.storage!.name,
            id: state.storage!.id,
          ),
        ),
      );
    }
    return const CenterLoadingIndicator();
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, StorageDetailState state) {
    if (state is StorageDetailSuccess) {
      return FloatingActionButton(
        tooltip: '添加物品',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider<ItemEditBloc>(
                create: (_) => ItemEditBloc(
                  storageRepository:
                      RepositoryProvider.of<StorageRepository>(context),
                ),
                child: ItemEditPage(
                  isEditing: false,
                  storage: state.storage,
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}

class PathBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;

  const PathBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  Size get preferredSize => const Size.fromHeight(40.0);
}
