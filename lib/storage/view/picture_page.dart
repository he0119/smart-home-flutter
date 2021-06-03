import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smarthome/storage/bloc/blocs.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';

class PicturePage extends Page {
  /// 图片 ID
  final String pictureId;

  PicturePage({
    required this.pictureId,
  }) : super(
          key: ValueKey(pictureId),
          name: '/picture/$pictureId',
        );

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<PictureBloc>(
            create: (context) => PictureBloc(
              storageRepository:
                  RepositoryProvider.of<StorageRepository>(context),
            )..add(PictureStarted(
                id: pictureId,
              )),
          ),
          BlocProvider<PictureEditBloc>(
            create: (context) => PictureEditBloc(
              storageRepository:
                  RepositoryProvider.of<StorageRepository>(context),
            ),
          ),
        ],
        child: PictureScreen(),
      ),
    );
  }
}

class PictureScreen extends StatelessWidget {
  PictureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PictureBloc, PictureState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: BlocListener<PictureEditBloc, PictureEditState>(
            listener: (context, state) {
              if (state is PictureDeleteSuccess) {
                showInfoSnackBar('图片 ${state.picture.description} 删除成功');
                Navigator.pop(context);
              }
              if (state is PictureEditFailure) {
                showErrorSnackBar(state.message);
              }
            },
            child: _buildBody(context, state),
          ),
          floatingActionButton: (state is PictureSuccess && kIsWeb)
              ? FloatingActionButton(
                  tooltip: '在新标签页中打开',
                  onPressed: () async {
                    await launchUrl(state.picture.url!);
                  },
                  child: const Icon(Icons.open_in_new),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PictureState state) {
    if (state is PictureFailure) {
      return ErrorMessageButton(
        onPressed: () {
          BlocProvider.of<PictureBloc>(context).add(
            PictureStarted(
              id: state.id,
            ),
          );
        },
        message: state.message,
      );
    }
    if (state is PictureSuccess) {
      return PhotoView(
        loadingBuilder: (context, event) => const CenterLoadingIndicator(),
        imageProvider: CachedNetworkImageProvider(
          state.picture.url!,
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 5,
        backgroundDecoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      );
    }
    return const CenterLoadingIndicator();
  }

  AppBar _buildAppBar(BuildContext context, PictureState state) {
    if (state is PictureSuccess) {
      return AppBar(
        title: state.picture.description.isNotEmpty
            ? Text('${state.picture.item!.name}（${state.picture.description}）')
            : Text('${state.picture.item!.name}（未命名）'),
        actions: [
          PopupMenuButton<PictureMenu>(
            onSelected: (value) async {
              if (value == PictureMenu.delete) {
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('删除 ${state.picture.description}'),
                    content: const Text('你确认要删除该图片么？'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('否'),
                      ),
                      TextButton(
                        onPressed: () {
                          showInfoSnackBar('正在删除...', duration: 1);
                          BlocProvider.of<PictureEditBloc>(context).add(
                            PictureDeleted(picture: state.picture),
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
                value: PictureMenu.delete,
                child: Text('删除'),
              ),
            ],
          )
        ],
      );
    }
    return AppBar(
      title: const Text('图片'),
    );
  }
}
