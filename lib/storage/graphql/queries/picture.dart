/// 获取图片信息
const String pictureQuery = r'''
query picture($id: ID!) {
  picture(id: $id) {
    id
    item {
      id
      name
    }
    description
    url
  }
}
''';
