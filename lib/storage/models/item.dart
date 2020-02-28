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
  final double price;
  final DateTime expirationDate;
  final DateTime updateDate;

  factory Item.fromJson(Map<String, dynamic> json) {
    // 检查是否拥有 ExpirationDate
    DateTime jsonExpirationDate;
    if (json['expirationDate'] == null) {
      jsonExpirationDate = null;
    } else {
      jsonExpirationDate = DateTime.parse(json['expirationDate']);
    }
    return Item(
      id: int.parse(json['id']),
      name: json['name'],
      number: json['number'],
      description: json['description'],
      expirationDate: jsonExpirationDate,
      price: json['price'],
      updateDate: DateTime.parse(json['updateDate']),
      storage: Storage(
        id: int.parse(json['storage']['id']),
        name: json['storage']['name'],
      ),
      editor: User(username: json['editor']['username']),
    );
  }
}
