/// 获取指定名称的物品
const String storageByNameQuery = r"""
query storageByName($name: String) {
  storages(name: $name) {
    edges {
      node {
        id
        name
      }
    }
  }
}
""";
