const String deletePictureMutation =
    r"""
mutation deletePicture($input: DeletePictureMutationInput!) {
  deletePicture(input: $input) {
    clientMutationId
  }
}
""";
