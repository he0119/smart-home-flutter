const String tokenAuth = r"""
mutation tokenAuth($input: ObtainJSONWebTokenInput!) {
  tokenAuth(input: $input) {
    token
    refreshToken
  }
}
""";
