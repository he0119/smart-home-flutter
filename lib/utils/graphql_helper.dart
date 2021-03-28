extension FlattenConnection on Map<String, dynamic> {
  /// 去掉 GraphQL Connection 中的 Edges 与 Node
  Map<String, dynamic> get flattenConnection => flatten(this);
}

/// 去掉 GraphQL Connection 中的 Edges 与 Node
Map<String, dynamic> flatten(Map<String, dynamic> json) {
  // 检查是否 Key 是列表
  for (var key in json.keys) {
    if (json[key] is Map) {
      if (json[key].keys.contains('edges')) {
        final List<dynamic> items = json[key]['edges'];
        if (items.isNotEmpty) {
          // 通过递归来处理
          final newitems =
              items.map((dynamic e) => flatten(e['node'])).toList();
          json[key] = newitems;
        } else {
          json[key] = [];
        }
      } else {
        json[key] = flatten(json[key]);
      }
    }
  }
  return json;
}
