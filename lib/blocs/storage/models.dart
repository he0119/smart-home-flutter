class User {
  const User({
    this.id,
    this.username,
  });

  final int id;
  final String username;
}

class Storage {
  const Storage({
    this.id,
    this.name,
    this.parent,
    this.description,
    this.isLoading: false,
  });

  final int id;
  final String name;
  final Storage parent;
  final String description;
  final bool isLoading;
}

class Item {
  const Item({
    this.id,
    this.name,
    this.number,
    this.storage,
    this.editor,
    this.description,
    this.expirationDate,
    this.price,
    this.updateDate,
    this.isLoading: false,
  });

  final String id;
  final String name;
  final int number;
  final Storage storage;
  final User editor;
  final String description;
  final String price;
  final DateTime expirationDate;
  final DateTime updateDate;
  final bool isLoading;
}
