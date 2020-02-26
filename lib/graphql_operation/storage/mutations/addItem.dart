const String addItem = r"""
mutation addItem($name: String!, $number: Int!, $storage: ID!, $description: String, $price: String, $expirationDate: DateTime) {
  addItem(input: {name: $name, number: $number, storage: $storage, description: $description, price: $price, expirationDate: $expirationDate}) {
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
