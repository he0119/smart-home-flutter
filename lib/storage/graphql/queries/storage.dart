/// 通过 ID 获取位置详情
const String storageQuery = r'''
query storage($id: ID!, $itemCursor: String, $storageCursor: String) {
  storage(id: $id) {
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
''';
