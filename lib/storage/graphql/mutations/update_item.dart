const String updateItemMutation = r'''
mutation updateItem($input: UpdateItemInput!) {
  updateItem(input: $input) {
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
