const String homepageQuery = r'''
query homepage($nearExpiredTime: DateTime!, $now: DateTime!) {
  recentlyCreatedItems: items(
    first: 10
    filters: {isDeleted: false}
    order: {createdAt: DESC}
  ) {
    edges {
      node {
        id
        name
        description
        createdAt
      }
    }
  }
  recentlyEditedItems: items(
    filters: {isDeleted: false}
    first: 10
    order: {editedAt: DESC}
  ) {
    edges {
      node {
        id
        name
        description
        editedAt
      }
    }
  }
  nearExpiredItems: items(
    filters: {isDeleted: false, expiredAt: {gt: $now, lt: $nearExpiredTime}}
    first: 10
    order: {expiredAt: DESC}
  ) {
    edges {
      node {
        id
        name
        description
        expiredAt
      }
    }
  }
  expiredItems: items(
    filters: {isDeleted: false, expiredAt: {lt: $now}}
    first: 10
    order: {expiredAt: DESC}
  ) {
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
''';
