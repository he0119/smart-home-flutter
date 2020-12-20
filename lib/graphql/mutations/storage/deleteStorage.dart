const String deleteStorageMutation = r"""
mutation deleteStorage($input: DeleteStorageMutationInput!) {
  deleteStorage(input: $input) {
    clientMutationId
  }
}
""";
