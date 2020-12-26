/// 获取指定名称的物品
const String itemByNameQuery = r"""
query itemByName($name: String) {
  items(name: $name) {
    edges {
      node {
        id
        name
      }
    }
  }
}
""";
