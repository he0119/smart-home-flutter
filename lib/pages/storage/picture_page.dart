import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/models/popup_menu.dart';
import 'package:smart_home/repositories/repositories.dart';
import 'package:smart_home/utils/launch_url.dart';
import 'package:smart_home/utils/show_snack_bar.dart';
import 'package:smart_home/widgets/center_loading_indicator.dart';
import 'package:smart_home/widgets/error_message_button.dart';

class PicturePage extends Page {
  /// 图片 ID
  final String pictureId;

  PicturePage({
    @required this.pictureId,
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
  PictureScreen({Key key}) : super(key: key);

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
          floatingActionButton: (state is PictureSuccess)
              ? FloatingActionButton(
                  tooltip: '使用浏览器打开',
                  child: Icon(Icons.open_in_new),
                  onPressed: () async {
                    await launchUrl(state.picture.url);
                  },
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
      return Center(
        child: CachedNetworkImage(
          placeholder: (context, url) => CircularProgressIndicator(),
          imageUrl: state.picture.url,
        ),
      );
    }
    return CenterLoadingIndicator();
  }

  AppBar _buildAppBar(BuildContext context, PictureState state) {
    if (state is PictureSuccess) {
      return AppBar(
        title: state.picture.description.isNotEmpty
            ? Text('${state.picture.item.name}（${state.picture.description}）')
            : Text('${state.picture.item.name}（未命名）'),
        actions: [
          PopupMenuButton<PictureMenu>(
            onSelected: (value) async {
              if (value == PictureMenu.delete) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('删除 ${state.picture.description}'),
                    content: Text('你确认要删除该图片么？'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('否'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('是'),
                        onPressed: () {
                          showInfoSnackBar('正在删除...', duration: 1);
                          BlocProvider.of<PictureEditBloc>(context).add(
                            PictureDeleted(picture: state.picture),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: PictureMenu.delete,
                child: Text('删除'),
              ),
            ],
          )
        ],
      );
    }
    return AppBar(
      title: Text('图片'),
    );
  }
}
