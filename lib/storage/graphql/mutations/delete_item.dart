const String deleteItemMutation = r'''
mutation deleteItem($input: DeleteItemInput!) {
  deleteItem(input: $input) {
    ... on Item {
      id
    }
  }
}
''';
