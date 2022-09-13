/// 获取所有的物品的名称
const String itemsQuery = r'''
query items($key: String) {
  items(filters: {name: {contains: $key}}) {
    edges {
      node {
        id
        name
      }
    }
  }
}
''';
