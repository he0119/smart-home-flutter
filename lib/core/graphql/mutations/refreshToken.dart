const String refreshTokenMutation = r'''
mutation refreshToken($input: RefreshInput!) {
  refreshToken(input: $input) {
    token
  }
}
''';
