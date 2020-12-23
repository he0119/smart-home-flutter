const String homepageQuery = r"""
query homepage($nearExpiredTime: DateTime!, $now: DateTime!) {
  recentlyCreatedItems: items(isDeleted: false, first:10, orderBy: "-created_at") {
    edges {
      node {
        id
        name
        description
        createdAt
      }
    }
  }
  recentlyEditedItems: items(isDeleted: false, first:10, orderBy: "-edited_at") {
    edges {
      node {
        id
        name
        description
        editedAt
      }
    }
  }
  nearExpiredItems: items(isDeleted: false, first:10, expiredAt_Gt: $now, expiredAt_Lt: $nearExpiredTime, orderBy: "-expired_at") {
    edges {
      node {
        id
        name
        description
        expiredAt
      }
    }
  }
  expiredItems: items(isDeleted: false, first:10, expiredAt_Lt: $now, orderBy: "-expired_at") {
    edges {
      node {
        id
        name
        description
        expiredAt
      }
    }
  }
}
""";
