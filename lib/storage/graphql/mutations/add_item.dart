const String addItemMutation = r'''
mutation addItem($input: AddItemInput!) {
  addItem(input: $input) {
    ... on Item {
      id
      name
      number
      storage {
        id
        name
      }
      description
      price
      expiredAt
      editedAt
      editedBy {
        username
      }
    }
  }
}
''';
