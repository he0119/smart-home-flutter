const String searchQuery = r"""
query search($key: String!) {
  search(key: $key) {
    items {
      id
      name
      description
    }
    storages {
      id
      name
      description
    }
  }
}
""";
