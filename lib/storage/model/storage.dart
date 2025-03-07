library;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smarthome/user/user.dart';

part 'storage.g.dart';

enum ItemType { expired, nearExpired, recentlyCreated, recentlyEdited, all }

@JsonSerializable()
class Storage extends Equatable {
  final String id;
  final String name;
  final Storage? parent;
  final List<Storage>? ancestors;
  final String? description;
  final List<Storage>? children;
  final List<Item>? items;

  const Storage({
    required this.id,
    required this.name,
    this.parent,
    this.ancestors,
    this.description,
    this.children,
    this.items,
  });

  factory Storage.fromJson(Map<String, dynamic> json) =>
      _$StorageFromJson(json);

  Map<String, dynamic> toJson() => _$StorageToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      name,
      parent,
      ancestors,
      description,
      children,
      items,
    ];
  }

  Storage copyWith({
    String? id,
    String? name,
    Storage? parent,
    List<Storage>? ancestors,
    String? description,
    List<Storage>? children,
    List<Item>? items,
  }) {
    return Storage(
      id: id ?? this.id,
      name: name ?? this.name,
      parent: parent ?? this.parent,
      ancestors: ancestors ?? this.ancestors,
      description: description ?? this.description,
      children: children ?? this.children,
      items: items ?? this.items,
    );
  }

  @override
  String toString() => name;
}

@JsonSerializable()
class Picture extends Equatable {
  final String id;
  final Item? item;
  final String? name;
  final String description;
  final String? url;
  final double? boxX;
  final double? boxY;
  final double? boxH;
  final double? boxW;

  const Picture({
    required this.id,
    this.item,
    this.name,
    required this.description,
    this.url,
    this.boxX,
    this.boxY,
    this.boxH,
    this.boxW,
  });

  factory Picture.fromJson(Map<String, dynamic> json) =>
      _$PictureFromJson(json);

  Map<String, dynamic> toJson() => _$PictureToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      item,
      name,
      description,
      url,
      boxX,
      boxY,
      boxH,
      boxW,
    ];
  }

  @override
  String toString() => description;
}

@JsonSerializable()
class Item extends Equatable {
  final String id;
  final String name;
  final int? number;
  final Storage? storage;
  final String? description;
  final double? price;
  final DateTime? expiredAt;
  final DateTime? editedAt;
  final User? editedBy;
  final DateTime? createdAt;
  final User? createdBy;
  final bool? isDeleted;
  final DateTime? deletedAt;
  final List<Item>? consumables;
  final List<Picture>? pictures;

  const Item({
    required this.id,
    required this.name,
    this.number,
    this.storage,
    this.description,
    this.price,
    this.expiredAt,
    this.editedAt,
    this.editedBy,
    this.createdAt,
    this.createdBy,
    this.isDeleted,
    this.deletedAt,
    this.consumables,
    this.pictures,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  List<Object?> get props {
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
      isDeleted,
      deletedAt,
      consumables,
      pictures,
    ];
  }

  @override
  String toString() => name;
}
