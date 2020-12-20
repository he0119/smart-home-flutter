library storage;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:smart_home/models/user.dart';

part 'storage.g.dart';

@JsonSerializable()
class Storage extends Equatable {
  final String id;
  final String name;
  final Storage parent;
  final String description;
  final List<Storage> children;
  final List<Item> items;

  Storage({
    this.id,
    this.name,
    this.parent,
    this.description,
    this.children,
    this.items,
  });

  factory Storage.fromJson(Map<String, dynamic> json) =>
      _$StorageFromJson(json);

  Map<String, dynamic> toJson() => _$StorageToJson(this);

  @override
  List<Object> get props {
    return [
      id,
      name,
      parent,
      description,
      children,
      items,
    ];
  }
}

@JsonSerializable()
class Item extends Equatable {
  final String id;
  final String name;
  final int number;
  final Storage storage;
  final String description;
  final double price;
  final DateTime expirationDate;
  final User editor;
  final DateTime updateDate;
  final DateTime dateAdded;

  Item({
    this.id,
    this.name,
    this.number,
    this.storage,
    this.description,
    this.price,
    this.expirationDate,
    this.editor,
    this.updateDate,
    this.dateAdded,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  List<Object> get props {
    return [
      id,
      name,
      number,
      storage,
      description,
      price,
      expirationDate,
      editor,
      updateDate,
      dateAdded,
    ];
  }
}
