import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smarthome/utils/gravatar_url.dart';

class CircleGravatar extends StatelessWidget {
  final String email;
  final int? size;

  const CircleGravatar({
    Key? key,
    required this.email,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // CachedNetworkImage 暂时不支持 Windows
    if (kIsWeb || !Platform.isWindows) {
      return CachedNetworkImage(
        imageUrl: getGravatarUrl(email: email, size: size),
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(getGravatarUrl(email: email, size: size)),
      );
    }
  }
}
