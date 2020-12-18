const String itemsQuery = r"""
query items {
  items {
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
