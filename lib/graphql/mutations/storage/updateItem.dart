// 注意不能给下一级添加 __typename，否则会出现 Stack Overflow 错误
// 我猜测应该是和 GraphQL 缓存与 JsonSerializable 有关系
const String updateItemMutation = r"""
mutation updateItem($input: UpdateItemInput!) {
  updateItem(input: $input) {
    item {
      id
      name
      number
      storage {
        id
        name
      }
      description
      price
      expirationDate
      updateDate
      editor {
        username
      }
    }
  }
}
""";
