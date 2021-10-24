const String addPictureMutation = r'''
mutation addPicture($input: AddPictureMutationInput!) {
  addPicture(input: $input) {
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
