import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyCircleAvatar extends StatelessWidget {
  final String? avatarUrl;

  const MyCircleAvatar({
    super.key,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null) {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Text('?', style: TextStyle(fontSize: 24)),
      );
    }
    // CachedNetworkImage 暂时不支持 Windows
    if (kIsWeb || !Platform.isWindows) {
      return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(url),
      );
    }
  }
}
