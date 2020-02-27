const String search = r"""
query search($key: String!) {
  search(key: $key) {
    items {
      id
      name
      number
      storage {
        id
        name
      }
      editor {
        username
      }
      description
      expirationDate
      price
      updateDate
    }
    storages {
      id
      name
      description
    }
  }
}
""";
