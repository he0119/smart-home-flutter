const String tokenAuth = r"""
mutation tokenAuth($username: String!, $password: String!) {
  tokenAuth(username: $username, password: $password) {
    token
    refreshToken
  }
}
""";
