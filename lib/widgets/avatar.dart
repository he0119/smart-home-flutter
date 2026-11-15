import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/utils/parse_url.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class MyCircleAvatar extends StatelessWidget {
  final String? avatarUrl;

  const MyCircleAvatar({super.key, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null) {
      final colors = Theme.of(context).colorScheme;
      return CircleAvatar(
        backgroundColor: colors.surfaceContainerHighest,
        child: Icon(
          Icons.person_outline,
          size: 24,
          color: colors.onSurfaceVariant,
        ),
      );
    }
    // CachedNetworkImage 暂时不支持 Windows
    if (kIsWeb || !Platform.isWindows) {
      return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(backgroundImage: imageProvider),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        cacheKey: getCacheKey(url),
      );
    } else {
      return CircleAvatar(backgroundImage: NetworkImage(url));
    }
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
/// 左边有头像，右边是没有头像时退回的人像占位图标。
@Preview(
  name: 'MyCircleAvatar',
  group: previewGroupWidgets,
  size: Size(180, 80),
)
Widget myCircleAvatarPreview() => const PreviewFrame(
  width: 180,
  padding: EdgeInsets.all(AppSpacing.md),
  child: Row(
    mainAxisAlignment: .center,
    children: <Widget>[
      MyCircleAvatar(
        avatarUrl: 'https://avatars.githubusercontent.com/u/5219550?v=4',
      ),
      SizedBox(width: AppSpacing.lg),
      MyCircleAvatar(avatarUrl: null),
    ],
  ),
);
