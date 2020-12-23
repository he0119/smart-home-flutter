const String consumablesQuery = r"""
query consumables($after: String) {
  consumables: items(isDeleted: false, consumables_Isnull: false, after: $after) {
    edges {
      node {
        id
        name
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
}
""";
