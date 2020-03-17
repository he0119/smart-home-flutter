const String updateItemMutation = r"""
mutation updateItem($input: UpdateItemInput!) {
  updateItem(input: $input) {
    item {
      __typename
      id
      name
      number
      storage {
        __typename
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
