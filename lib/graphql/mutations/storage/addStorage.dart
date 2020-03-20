const String addStorageMutation = r"""
mutation addStorage($input: AddStorageInput!) {
  addStorage(input: $input) {
    storage {
      id
      name
      description
    }
  }
}
""";
