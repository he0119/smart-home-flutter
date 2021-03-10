import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/storage/blocs.dart';
import 'package:smart_home/repositories/repositories.dart';
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
          body: _buildBody(context, state),
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
      );
    }
    return AppBar(
      title: Text('图片'),
    );
  }
}
