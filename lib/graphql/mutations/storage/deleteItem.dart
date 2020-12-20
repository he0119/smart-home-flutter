const String deleteItemMutation = r"""
mutation deleteItem($input: DeleteItemMutationInput!) {
  deleteItem(input: $input) {
    clientMutationId
  }
}
""";
