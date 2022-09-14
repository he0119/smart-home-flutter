const String updatePictureMutation = r'''
mutation updatePicture($input: UpdatePictureInput!) {
  updatePicture(input: $input) {
    ... on Picture {
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
