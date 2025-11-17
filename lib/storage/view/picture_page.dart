import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/providers.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/utils/parse_url.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/error_message_button.dart';

class PicturePage extends Page {
  /// 图片 ID
  final String pictureId;

  PicturePage({required this.pictureId})
    : super(key: ValueKey(pictureId), name: '/picture/$pictureId');

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => PictureScreen(pictureId: pictureId),
    );
  }
}

class PictureScreen extends ConsumerStatefulWidget {
  final String pictureId;

  const PictureScreen({super.key, required this.pictureId});

  @override
  ConsumerState<PictureScreen> createState() => _PictureScreenState();
}

class _PictureScreenState extends ConsumerState<PictureScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pictureProvider(widget.pictureId));

    ref.listen<PictureEditState>(pictureEditProvider, (previous, state) {
      if (state.status == PictureEditStatus.deleteSuccess) {
        showInfoSnackBar('图片 ${state.picture?.description} 删除成功');
        Navigator.of(context).pop();
      }
      if (state.status == PictureEditStatus.failure) {
        showErrorSnackBar(state.errorMessage);
      }
    });

    return state.when(
      data: (picture) => Scaffold(
        appBar: AppBar(
          title: picture.description.isNotEmpty
              ? Text('${picture.item!.name}（${picture.description}）')
              : Text('${picture.item!.name}（未命名）'),
          actions: [
            PopupMenuButton<PictureMenu>(
              onSelected: (value) async {
                if (value == PictureMenu.delete) {
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('删除 ${picture.description}'),
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
                            ref
                                .read(pictureEditProvider.notifier)
                                .deletePicture(picture);
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
                  value: PictureMenu.delete,
                  child: Text('删除'),
                ),
              ],
            ),
          ],
        ),
        body: PhotoView(
          loadingBuilder: (context, event) => const CenterLoadingIndicator(),
          imageProvider: CachedNetworkImageProvider(
            picture.url!,
            cacheKey: getCacheKey(picture.url!),
          ),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 5,
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        floatingActionButton: kIsWeb
            ? FloatingActionButton(
                tooltip: '在新标签页中打开',
                onPressed: () async {
                  await launchUrl(picture.url!);
                },
                child: const Icon(Icons.open_in_new),
              )
            : null,
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('加载中...')),
        body: const CenterLoadingIndicator(),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('图片')),
        body: ErrorMessageButton(
          onPressed: () {
            ref.read(pictureProvider(widget.pictureId).notifier).refresh();
          },
          message: error.toString(),
        ),
      ),
    );
  }
}
