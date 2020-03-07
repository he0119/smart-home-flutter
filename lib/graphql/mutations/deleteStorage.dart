const String deleteStorageMutation = r"""
mutation deleteStorage($id: ID!) {
  deleteStorage(id: $id) {
    deletedId
  }
}
""";
