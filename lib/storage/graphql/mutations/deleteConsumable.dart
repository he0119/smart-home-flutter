const String deleteConsumableMutation = r'''
mutation deleteConsumable($input: DeleteConsumableMutationInput!) {
  deleteConsumable(input: $input) {
    item {
      id
      name
      consumables(isDeleted: false) {
        edges {
          node {
            id
            name
            expiredAt
          }
        }
      }
    }
  }
}
''';
