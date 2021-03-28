const String updateStorageMutation = r'''
mutation updateStorage($input: UpdateStorageMutationInput!) {
  updateStorage(input: $input) {
    storage {
      id
      name
      description
      parent {
        id
      }
    }
  }
}
''';
