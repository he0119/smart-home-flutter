const String updateStorageMutation = r"""
mutation updateStorage($input: UpdateStorageInput!) {
  updateStorage(input: $input) {
    storage {
      id
      name
      description
    }
  }
}
""";
