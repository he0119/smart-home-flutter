const String homepageQuery = r"""
query homepage {
  recentlyAddedItems(number: 10) {
    __typename
    id
    name
    description
    dateAdded
  }
  recentlyUpdatedItems(number: 10) {
    __typename
    id
    name
    description
    updateDate
  }
  nearExpiredItems(within: 30, number: 10) {
    __typename
    id
    name
    description
    expirationDate
  }
  expiredItems(number: 10) {
    __typename
    id
    name
    description
    expirationDate
  }
}
""";
