// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageInfo _$PageInfoFromJson(Map<String, dynamic> json) {
  return PageInfo(
    hasNextPage: json['hasNextPage'] as bool,
    hasPreviousPage: json['hasPreviousPage'] as bool?,
    startCursor: json['startCursor'] as String?,
    endCursor: json['endCursor'] as String?,
  );
}

Map<String, dynamic> _$PageInfoToJson(PageInfo instance) => <String, dynamic>{
      'hasNextPage': instance.hasNextPage,
      'hasPreviousPage': instance.hasPreviousPage,
      'startCursor': instance.startCursor,
      'endCursor': instance.endCursor,
    };
