/// 获取指定名称的物品
const String storageByNameQuery = r'''
query storageByName($name: String!, $itemCursor: String, $storageCursor: String) {
  storage: storages(name: $name) {
    edges {
      node {
        id
        name
        description
        ancestors {
          edges {
            node {
              id
              name
              ancestors {
                edges {
                  node {
                    id
                    name
                  }
                }
              }
            }
          }
        }
        children(after: $storageCursor) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            node {
              id
              name
              description
              ancestors {
                edges {
                  node {
                    id
                    name
                  }
                }
              }
            }
          }
        }
        items(isDeleted: false, after: $itemCursor) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            node {
              id
              name
              description
            }
          }
        }
        parent {
          id
          name
        }
      }
    }
  }
}
''';
