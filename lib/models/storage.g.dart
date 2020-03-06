// GENERATED CODE - DO NOT MODIFY BY HAND

part of storage;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Storage _$StorageFromJson(Map<String, dynamic> json) {
  return Storage(
    json['id'] as String,
    json['name'] as String,
    json['parent'] == null
        ? null
        : Storage.fromJson(json['parent'] as Map<String, dynamic>),
    json['description'] as String,
    (json['children'] as List)
        ?.map((e) =>
            e == null ? null : Storage.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['items'] as List)
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
    json['id'] as String,
    json['name'] as String,
    json['number'] as int,
    json['storage'] == null
        ? null
        : Storage.fromJson(json['storage'] as Map<String, dynamic>),
    json['description'] as String,
    (json['price'] as num)?.toDouble(),
    json['expirationDate'] == null
        ? null
        : DateTime.parse(json['expirationDate'] as String),
    json['editor'] == null
        ? null
        : User.fromJson(json['editor'] as Map<String, dynamic>),
    json['updateDate'] == null
        ? null
        : DateTime.parse(json['updateDate'] as String),
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
    };
