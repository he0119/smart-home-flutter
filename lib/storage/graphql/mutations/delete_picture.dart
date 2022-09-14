const String deletePictureMutation = r'''
mutation deletePicture($input: DeletePictureInput!) {
  deletePicture(input: $input) {
    ... on Picture {
      id
    }
  }
}
''';
