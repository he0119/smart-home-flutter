/// 获取所有的存储位置的名称
const String storagesQuery = r'''
query storages($key: String) {
  storages(name_Icontains: $key) {
    edges {
      node {
        id
        name
      }
    }
  }
}
''';
