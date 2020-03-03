const String storagesQuery = r"""
query storages {
  storages {
    id
    name
    description
  }
}
""";

const String storageQuery = r"""
query storage($id: ID!) {
  storage(id: $id) {
    id
    name
    description
    children {
      id
      name
    }
    items {
      id
      name
      number
      storage {
        id
        name
      }
    }
  }
}
""";

