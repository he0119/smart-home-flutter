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
      description
    }
    items {
      id
      name
      number
      description
      storage {
        id
        name
      }
    }
    parent {
      id
      name
    }
  }
  storageAncestors(id: $id) {
    id
    name
  }
}
""";

