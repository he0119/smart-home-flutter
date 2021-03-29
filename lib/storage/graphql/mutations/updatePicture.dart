const String updatePictureMutation = r'''
mutation updatePicture($input: UpdatePictureMutationInput!) {
  updatePicture(input: $input) {
    picture {
      id
      name
      description
      url
      boxX
      boxY
      boxH
      boxW
    }
  }
}
''';
