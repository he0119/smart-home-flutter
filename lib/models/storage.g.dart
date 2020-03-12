// GENERATED CODE - DO NOT MODIFY BY HAND

part of storage;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Storage _$StorageFromJson(Map<String, dynamic> json) {
  return Storage(
    id: json['id'] as String,
    name: json['name'] as String,
    parent: json['parent'] == null
        ? null
        : Storage.fromJson(json['parent'] as Map<String, dynamic>),
    description: json['description'] as String,
    children: (json['children'] as List)
        ?.map((e) =>
            e == null ? null : Storage.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    items: (json['items'] as List)
        ?.map(
            (e) => e == null ? null : Item.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$StorageToJson(Storage instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parent': instance.parent,
      'description': instance.description,
      'children': instance.children,
      'items': instance.items,
    };

Item _$ItemFromJson(Map<String, dynamic> json) {
  return Item(
    id: json['id'] as String,
    name: json['name'] as String,
    number: json['number'] as int,
    storage: json['storage'] == null
        ? null
        : Storage.fromJson(json['storage'] as Map<String, dynamic>),
    description: json['description'] as String,
    price: (json['price'] as num)?.toDouble(),
    expirationDate: json['expirationDate'] == null
        ? null
        : DateTime.parse(json['expirationDate'] as String),
    editor: json['editor'] == null
        ? null
        : User.fromJson(json['editor'] as Map<String, dynamic>),
    updateDate: json['updateDate'] == null
        ? null
        : DateTime.parse(json['updateDate'] as String),
    dateAdded: json['dateAdded'] == null
        ? null
        : DateTime.parse(json['dateAdded'] as String),
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'number': instance.number,
      'storage': instance.storage,
      'description': instance.description,
      'price': instance.price,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'editor': instance.editor,
      'updateDate': instance.updateDate?.toIso8601String(),
      'dateAdded': instance.dateAdded?.toIso8601String(),
    };
