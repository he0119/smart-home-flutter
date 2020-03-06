const String storagesQuery = r"""
query storages {
  storages {
    __typename
    id
    name
    description
  }
}
""";

const String storageQuery = r"""
query storage($id: ID!) {
  storage(id: $id) {
    __typename
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
  }
}
""";

