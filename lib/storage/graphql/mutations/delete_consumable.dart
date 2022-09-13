const String deleteConsumableMutation = r'''
mutation deleteConsumable($input: DeleteConsumableInput!) {
  deleteConsumable(input: $input) {
    ... on Item {
      id
      name
      consumables(filters: {isDeleted: false}) {
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
