const String expiredItemsQuery = r"""
query expiredItems($number: Int) {
  expiredItems(number: $number) {
    __typename
    id
    name
    description
    expirationDate
  }
}
""";
