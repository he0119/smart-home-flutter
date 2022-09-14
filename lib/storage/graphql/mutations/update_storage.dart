const String updateStorageMutation = r'''
mutation updateStorage($input: UpdateStorageInput!) {
  updateStorage(input: $input) {
    ... on Storage {
      id
      name
      description
      parent {
        id
        name
      }
    }
  }
}
''';
