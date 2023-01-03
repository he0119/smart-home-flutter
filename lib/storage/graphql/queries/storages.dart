/// 获取所有的存储位置的名称
const String storagesQuery = r'''
query storages($key: String) {
  storages(filters: {name: {iContains: $key}}) {
    edges {
      node {
        id
        name
        parent {
          id
          name
        }
      }
    }
  }
}
''';
