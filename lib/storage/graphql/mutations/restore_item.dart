const String restoreItemMutation = r'''
mutation restoreItem($input: RestoreItemMutationInput!) {
  restoreItem(input: $input) {
    clientMutationId
  }
}
''';
