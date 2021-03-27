const String addConsumableMutation = r"""
mutation addConsumable($input: AddConsumableMutationInput!) {
  addConsumable(input: $input) {
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
