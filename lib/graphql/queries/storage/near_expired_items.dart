const String nearExpiredItemsQuery = r"""
query nearExpiredItems($within: Int!, $number: Int) {
  nearExpiredItems(within: $within, number: $number) {
    __typename
    id
    name
    description
    expirationDate
  }
}
""";
