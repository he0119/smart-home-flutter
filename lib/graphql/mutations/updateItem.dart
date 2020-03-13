const String updateItemMutation = r"""
mutation updateItem($input: UpdateItemInput!) {
  updateItem(input: $input) {
    item {
      __typename
      id
      name
      number
      storage {
        id
        name
        items {
          __typename
          id
          name
          description
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
