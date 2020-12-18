const String nearExpiredItemsQuery = r"""
query nearExpiredItems($within: Int!, $number: Int) {
  nearExpiredItems(within: $within, number: $number) {
    id
    name
    description
    expirationDate
  }
}
""";
