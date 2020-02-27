const String storages = r"""
query storages {
  storages {
    id
    name
    description
  }
}
""";

const String storage = r"""
query storage($id: ID!) {
  storage(id: $id) {
    id
    name
    description
  }
}
""";

