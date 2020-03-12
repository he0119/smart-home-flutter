const String recentlyUpdatedItemsQuery = r"""
query recentlyUpdatedItems($number: Int!) {
  recentlyUpdatedItems(number: $number) {
    __typename
    id
    name
    description
    updateDate
  }
}
""";
