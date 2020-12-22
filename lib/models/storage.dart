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

  Storage copyWith({
    String id,
    String name,
    Storage parent,
    String description,
    List<Storage> children,
    List<Item> items,
  }) {
    return Storage(
      id: id ?? this.id,
      name: name ?? this.name,
      parent: parent ?? this.parent,
      description: description ?? this.description,
      children: children ?? this.children,
      items: items ?? this.items,
    );
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
  final DateTime expiredAt;
  final DateTime editedAt;
  final User editedBy;
  final DateTime createdAt;
  final User createdBy;

  Item({
    this.id,
    this.name,
    this.number,
    this.storage,
    this.description,
    this.price,
    this.expiredAt,
    this.editedAt,
    this.editedBy,
    this.createdAt,
    this.createdBy,
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
      expiredAt,
      editedAt,
      editedBy,
      createdAt,
      createdBy,
    ];
  }
}
