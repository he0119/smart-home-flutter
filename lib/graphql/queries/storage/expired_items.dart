const String expiredItemsQuery = r"""
query expiredItems($number: Int) {
  expiredItems(number: $number) {
    id
    name
    description
    expirationDate
  }
}
""";
