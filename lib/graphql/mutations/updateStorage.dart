const String updateStorageMutation = r"""
mutation updateStorage($input: UpdateStorageInput!) {
  updateStorage(input: $input) {
    storage {
      __typename
      id
      name
      description
      parent {
        __typename
        id
      }
    }
  }
}
""";
