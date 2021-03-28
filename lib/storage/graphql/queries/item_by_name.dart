/// 获取指定名称的物品
const String itemByNameQuery = r'''
query itemByName($name: String) {
  item: items(name: $name) {
    edges {
      node {
        id
        name
        number
        storage {
          id
          name
        }
        description
        price
        expiredAt
        consumables(isDeleted: false) {
          edges {
            node {
              id
              name
              expiredAt
            }
          }
        }
        editedAt
        createdAt
        editedBy {
          username
        }
        createdBy {
          username
        }
        pictures {
          edges {
            node {
              id
              description
            }
          }
        }
      }
    }
  }
}
''';
