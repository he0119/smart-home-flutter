const String logoutMutation = r'''
mutation logout {
  logout {
    ... on User {
      username
    }
  }
}
''';
