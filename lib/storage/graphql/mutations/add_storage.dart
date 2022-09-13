const String addStorageMutation = r'''
mutation addStorage($input: AddStorageInput!) {
  addStorage(input: $input) {
    ... on Storage {
      id
      name
      description
    }
  }
}
''';
