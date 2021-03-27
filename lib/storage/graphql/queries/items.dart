/// 获取所有的物品的名称
const String itemsQuery = r"""
query items($key: String) {
  items(name_Icontains: $key) {
    edges {
      node {
        id
        name
      }
    }
  }
}
""";
