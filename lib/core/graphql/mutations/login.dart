const String loginMutation = r'''
mutation login($input: LoginInput!) {
  login(input: $input) {
    ... on User {
      username
      email
      avatarUrl
    }
  }
}
''';
