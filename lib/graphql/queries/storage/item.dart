const String itemsQuery = r"""
query items {
  items {
    __typename
    id
    name
    number
    storage {
      id
      name
    }
    description
    price
    expirationDate
    updateDate
    dateAdded
    editor {
      username
    }
  }
}
""";

const String itemQuery = r"""
query item($id: ID!) {
  item(id: $id) {
    __typename
    id
    name
    number
    storage {
      id
      name
    }
    description
    price
    expirationDate
    updateDate
    dateAdded
    editor {
      username
    }
  }
}
""";
