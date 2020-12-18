const String recentlyAddedItemsQuery = r"""
query recentlyAddedItems($number: Int!) {
  recentlyAddedItems(number: $number) {
    id
    name
    description
    dateAdded
  }
}
""";
