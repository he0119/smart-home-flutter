const String homepageQuery = r"""
query homepage($nearExpiredTime: DateTime!, $now: DateTime!) {
  recentlyAddedItems: items(first:10, orderBy: "-date_added") {
    edges {
      node {
        id
        name
        description
        dateAdded
      }
    }
  }
  recentlyUpdatedItems: items(first:10, orderBy: "-update_date") {
    edges {
      node {
        id
        name
        description
        updateDate
      }
    }
  }
  nearExpiredItems: items(first:10, expirationDate_Gt: $now, expirationDate_Lt: $nearExpiredTime, orderBy: "-expiration_date") {
    edges {
      node {
        id
        name
        description
        expirationDate
      }
    }
  }
  expiredItems: items(first:10, expirationDate_Lt: $now, orderBy: "-expiration_date") {
    edges {
      node {
        id
        name
        description
        expirationDate
      }
    }
  }
}
""";
