const String addStorage = r"""
mutation addStorage($name: String!, $description: String, $parent: ID) {
  addStorage(input: {name: $name, description: $description, parent: $parent}) {
    storage {
      id
      name
      description
    }
  }
}
""";
