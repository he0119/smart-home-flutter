const String topicsQuery = r"""
query topics($number: Int) {
  topics(number: $number) {
    id
    title
    description
    isOpen
    user {
      username
      email
    }
    dateCreated
    dateModified
  }
}
""";
