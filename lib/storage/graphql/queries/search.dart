const String searchQuery = r"""
query search($isDeleted: Boolean, $key: String!) {
  itemName: items(isDeleted: $isDeleted, name_Icontains: $key) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  itemDescription: items(isDeleted: $isDeleted, description_Icontains: $key) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  storageName: storages(name_Icontains: $key) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  storageDescription: storages(description_Icontains: $key) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
}
""";
