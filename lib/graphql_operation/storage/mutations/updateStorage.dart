const String updateStorage = r"""
mutation updateStorage($id: ID!, $name: String, $description: String, $parent: ID) {
  updateStorage(input: {id: $id, name: $name, description: $description, parent: $parent}) {
    storage {
      id
      name
      description
    }
  }
}
""";
