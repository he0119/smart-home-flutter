const String updateItemMutation = r"""
mutation updateItem($input: UpdateItemMutationInput!) {
  updateItem(input: $input) {
    item {
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
""";
