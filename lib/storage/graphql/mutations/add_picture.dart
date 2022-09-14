const String addPictureMutation = r'''
mutation addPicture($input: AddPictureInput!) {
  addPicture(input: $input) {
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
