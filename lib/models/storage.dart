library storage;

import 'package:json_annotation/json_annotation.dart';
import 'package:smart_home/models/user.dart';

part 'storage.g.dart';

@JsonSerializable()
class Storage {
  Storage(this.id, this.name, this.parent, this.description, this.children,
      this.items);

  final String id;
  final String name;
  final Storage parent;
  final String description;
  final List<Storage> children;
  final List<Item> items;

  factory Storage.fromJson(Map<String, dynamic> json) =>
      _$StorageFromJson(json);

  Map<String, dynamic> toJson() => _$StorageToJson(this);
}

@JsonSerializable()
class Item {
  Item(this.id, this.name, this.number, this.storage, this.description,
      this.price, this.expirationDate, this.editor, this.updateDate);

  final String id;
  final String name;
  final int number;
  final Storage storage;
  final String description;
  final double price;
  final DateTime expirationDate;
  final User editor;
  final DateTime updateDate;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
