const String addStorageMutation = r'''
mutation addStorage($input: AddStorageMutationInput!) {
  addStorage(input: $input) {
    storage {
      id
      name
      description
    }
  }
}
''';
