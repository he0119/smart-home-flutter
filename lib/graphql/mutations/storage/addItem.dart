const String addItemMutation = r"""
mutation addItem($input: AddItemMutationInput!) {
  addItem(input: $input) {
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
