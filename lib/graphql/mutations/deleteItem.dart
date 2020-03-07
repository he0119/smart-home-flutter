const String deleteItemMutation = r"""
mutation deleteItem($id: ID!) {
  deleteItem(id: $id) {
    deletedId
  }
}
""";
