const String searchQuery = r"""
query search($key: String!) {
  itemName: items(name_Icontains: $key) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  itemDescription: items(description_Icontains: $key) {
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
