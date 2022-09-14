const String deleteStorageMutation = r'''
mutation deleteStorage($input: DeleteStorageInput!) {
  deleteStorage(input: $input) {
    ... on Storage {
      id
    }
  }
}
''';
