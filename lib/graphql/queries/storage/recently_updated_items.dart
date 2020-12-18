const String recentlyUpdatedItemsQuery = r"""
query recentlyUpdatedItems($number: Int!) {
  recentlyUpdatedItems(number: $number) {
    id
    name
    description
    updateDate
  }
}
""";
