part of 'models.dart';

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
  });

  final int id;
  final String name;
  final int number;
  final Storage storage;
  final User editor;
  final String description;
  final String price;
  final DateTime expirationDate;
  final DateTime updateDate;
}
