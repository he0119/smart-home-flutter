const String restoreItemMutation = r'''
mutation restoreItem($input: RestoreItemInput!) {
  restoreItem(input: $input) {
    ... on Item {
      id
    }
  }
}
''';
