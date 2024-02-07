/// 从 url 中获取缓存 key
String getCacheKey(String url) {
  final uri = Uri.parse(url);
  return '${uri.host}:${uri.port}${uri.path}';
}
