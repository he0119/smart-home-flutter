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
    expiredAt: json['expiredAt'] == null
        ? null
        : DateTime.parse(json['expiredAt'] as String),
    editedAt: json['editedAt'] == null
        ? null
        : DateTime.parse(json['editedAt'] as String),
    editedBy: json['editedBy'] == null
        ? null
        : User.fromJson(json['editedBy'] as Map<String, dynamic>),
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    createdBy: json['createdBy'] == null
        ? null
        : User.fromJson(json['createdBy'] as Map<String, dynamic>),
    isDeleted: json['isDeleted'] as bool,
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );
}

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'number': instance.number,
      'storage': instance.storage,
      'description': instance.description,
      'price': instance.price,
      'expiredAt': instance.expiredAt?.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'editedBy': instance.editedBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
