/// 获取物品详情
const String itemQuery = r"""
query item($id: ID!) {
  item(id: $id) {
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
    consumables {
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
  }
}
""";
