library storage;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'user.dart';

part 'storage.g.dart';

abstract class Storage implements Built<Storage, StorageBuilder> {
  static Serializer<Storage> get serializer => _$storageSerializer;

  String get id;
  String get name;
  @nullable
  Storage get parent;
  @nullable
  String get description;

  Storage._();
  factory Storage([void Function(StorageBuilder) updates]) = _$Storage;
}

abstract class Item implements Built<Item, ItemBuilder> {
  static Serializer<Item> get serializer => _$itemSerializer;

  String get id;
  String get name;
  int get number;
  Storage get storage;
  User get editor;
  @nullable
  String get description;
  @nullable
  double get price;
  @nullable
  DateTime get expirationDate;
  DateTime get updateDate;

  Item._();
  factory Item([void Function(ItemBuilder) updates]) = _$Item;
}
