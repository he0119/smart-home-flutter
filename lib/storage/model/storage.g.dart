// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Storage _$StorageFromJson(Map<String, dynamic> json) => Storage(
  id: json['id'] as String,
  name: json['name'] as String,
  parent: json['parent'] == null
      ? null
      : Storage.fromJson(json['parent'] as Map<String, dynamic>),
  ancestors: (json['ancestors'] as List<dynamic>?)
      ?.map((e) => Storage.fromJson(e as Map<String, dynamic>))
      .toList(),
  description: json['description'] as String?,
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => Storage.fromJson(e as Map<String, dynamic>))
      .toList(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StorageToJson(Storage instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'parent': instance.parent,
  'ancestors': instance.ancestors,
  'description': instance.description,
  'children': instance.children,
  'items': instance.items,
};

Picture _$PictureFromJson(Map<String, dynamic> json) => Picture(
  id: json['id'] as String,
  item: json['item'] == null
      ? null
      : Item.fromJson(json['item'] as Map<String, dynamic>),
  name: json['name'] as String?,
  description: json['description'] as String,
  url: json['url'] as String?,
  boxX: (json['boxX'] as num?)?.toDouble(),
  boxY: (json['boxY'] as num?)?.toDouble(),
  boxH: (json['boxH'] as num?)?.toDouble(),
  boxW: (json['boxW'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
  'id': instance.id,
  'item': instance.item,
  'name': instance.name,
  'description': instance.description,
  'url': instance.url,
  'boxX': instance.boxX,
  'boxY': instance.boxY,
  'boxH': instance.boxH,
  'boxW': instance.boxW,
};

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  id: json['id'] as String,
  name: json['name'] as String,
  number: (json['number'] as num?)?.toInt(),
  storage: json['storage'] == null
      ? null
      : Storage.fromJson(json['storage'] as Map<String, dynamic>),
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toDouble(),
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
  isDeleted: json['isDeleted'] as bool?,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  consumables: (json['consumables'] as List<dynamic>?)
      ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
      .toList(),
  pictures: (json['pictures'] as List<dynamic>?)
      ?.map((e) => Picture.fromJson(e as Map<String, dynamic>))
      .toList(),
);

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
  'consumables': instance.consumables,
  'pictures': instance.pictures,
};
