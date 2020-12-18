const String homepageQuery = r"""
query homepage {
  recentlyAddedItems(number: 10) {
    id
    name
    description
    dateAdded
  }
  recentlyUpdatedItems(number: 10) {
    id
    name
    description
    updateDate
  }
  nearExpiredItems(within: 365, number: 10) {
    id
    name
    description
    expirationDate
  }
  expiredItems(number: 10) {
    id
    name
    description
    expirationDate
  }
}
""";
