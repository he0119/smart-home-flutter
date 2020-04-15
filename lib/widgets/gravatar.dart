import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/utils/gravatar_url.dart';

class CircleGravatar extends StatelessWidget {
  final String email;

  const CircleGravatar({Key key, @required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // CachedNetworkImage 暂时不支持 web
    if (!kIsWeb) {
      return CachedNetworkImage(
        imageUrl: getGravatarUrl(email: email),
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(getGravatarUrl(email: email)),
      );
    }
  }
}
