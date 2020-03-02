const String tokenAuth = r"""
mutation login($username: String!, $password: String!) {
  tokenAuth(username: $username, password: $password) {
    token
  }
}
""";
