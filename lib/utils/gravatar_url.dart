import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

/// 获取 Gravatar 的网址
String getGravatarUrl({@required String email, int scale = 80}) {
  String emailMd5 = md5.convert(utf8.encode(email)).toString();
  return 'https://www.gravatar.com/avatar/$emailMd5?s=$scale';
}
