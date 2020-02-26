const String items = r"""
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
    editor {
      username
    }
  }
}
""";

const String item = r"""
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
    editor {
      username
    }
  }
}
""";
