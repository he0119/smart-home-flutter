import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smarthome/storage/model/models.dart';
import 'package:smarthome/storage/providers/providers.dart';
import 'package:smarthome/utils/launch_url.dart';
import 'package:smarthome/utils/parse_url.dart';
import 'package:smarthome/utils/show_confirm_dialog.dart';
import 'package:smarthome/utils/show_snack_bar.dart';
import 'package:smarthome/widgets/center_loading_indicator.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/state_views.dart';

class PicturePage extends StatelessWidget {
  /// 图片 ID
  final String pictureId;

  const PicturePage({super.key, required this.pictureId});

  @override
  Widget build(BuildContext context) {
    return PictureScreen(pictureId: pictureId);
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
      data: (picture) {
        final itemName = picture.item?.name ?? '图片';
        final title = picture.description.isEmpty
            ? '$itemName（未命名）'
            : '$itemName（${picture.description}）';
        return MySliverScaffold(
          appBarSize: AppBarSize.normal,
          // 看图页不需要限宽，宽屏上直接铺满
          contentMaxWidth: double.infinity,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: <Widget>[
            PopupMenuButton<PictureMenu>(
              tooltip: '图片操作',
              onSelected: (value) async {
                if (value == PictureMenu.delete) {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: '删除 ${picture.description}',
                    message: '删除后无法恢复，确认删除这张图片？',
                    confirmLabel: '删除',
                    destructive: true,
                  );
                  if (!confirmed) {
                    return;
                  }
                  showInfoSnackBar('正在删除...', duration: 1);
                  ref.read(pictureEditProvider.notifier).deletePicture(picture);
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<PictureMenu>>[
                const PopupMenuItem(
                  value: PictureMenu.delete,
                  child: Text('删除'),
                ),
              ],
            ),
          ],
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: PhotoView(
              loadingBuilder: (context, event) =>
                  const CenterLoadingIndicator(),
              imageProvider: CachedNetworkImageProvider(
                picture.url!,
                cacheKey: getCacheKey(picture.url!),
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 5,
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
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
        );
      },
      loading: () => const MySliverScaffold(
        appBarSize: AppBarSize.normal,
        title: Text('图片'),
        sliver: SliverCenterLoadingIndicator(),
      ),
      error: (error, stack) => MySliverScaffold(
        appBarSize: AppBarSize.normal,
        title: const Text('图片'),
        sliver: SliverErrorState(
          onRetry: () {
            ref.read(pictureProvider(widget.pictureId).notifier).refresh();
          },
          message: error.toString(),
        ),
      ),
    );
  }
}
