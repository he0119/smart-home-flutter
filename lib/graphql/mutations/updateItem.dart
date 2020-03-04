const String updateItemMutation = r"""
mutation updateItem($input: UpdateItemInput!) {
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
      expirationDate
      updateDate
      editor {
        username
      }
    }
  }
}
""";
