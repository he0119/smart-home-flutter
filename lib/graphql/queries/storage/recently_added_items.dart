const String recentlyAddedItemsQuery = r"""
query recentlyAddedItems($number: Int!) {
  recentlyAddedItems(number: $number) {
    __typename
    id
    name
    description
    dateAdded
  }
}
""";
