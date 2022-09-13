const String addConsumableMutation = r'''
mutation addConsumable($input: AddConsumableInput!) {
  addConsumable(input: $input) {
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
