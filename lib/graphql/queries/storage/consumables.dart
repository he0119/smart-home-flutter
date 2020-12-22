const String consumablesQuery = r"""
query consumables($after: String) {
  consumables: items(consumables_Isnull: false, after: $after) {
    edges {
      node {
        id
        name
        consumables {
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
