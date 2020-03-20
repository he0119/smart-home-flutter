const String addItemMutation = r"""
mutation addItem($input: AddItemInput!) {
  addItem(input: $input) {
    item {
      __typename
      id
      name
      number
      storage {
        id
        name
      }
      description
      price
      expirationDate
      updateDate
      editor {
        username
      }
    }
  }
}
""";
