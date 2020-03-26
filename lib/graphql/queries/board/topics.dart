const String topicsQuery = r"""
query topics($number: Int) {
  topics(number: $number) {
    __typename
    id
    title
    description
    isOpen
    user {
      username
    }
    dateCreated
    dateModified
  }
}
""";
