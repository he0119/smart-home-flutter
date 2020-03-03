const String refreshTokenMutation = r"""
mutation refreshToken($token: String!) {
  refreshToken(refreshToken: $token) {
    token
  }
}
""";
