import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 获取 Gravatar 的网址
String getGravatarUrl({required String email, int? size}) {
  // Gravatar 默认大小为 80px by 80px
  // https://en.gravatar.com/site/implement/images/
  size = size ?? 80;
  String emailMd5 = md5.convert(utf8.encode(email)).toString();
  return 'https://www.gravatar.com/avatar/$emailMd5?s=$size';
}
