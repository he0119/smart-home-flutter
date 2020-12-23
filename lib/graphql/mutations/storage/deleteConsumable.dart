const String deleteConsumableMutation = r"""
mutation deleteConsumable($input: DeleteConsumableMutationInput!) {
  deleteConsumable(input: $input) {
    item {
      id
      consumables(isDeleted: false) {
        edges {
          node {
            id
            name
            expiredAt
          }
        }
      }
    }
  }
}
""";
