import 'package:json_annotation/json_annotation.dart';

part 'relay.g.dart';

@JsonSerializable()
class PageInfo {
  final bool hasNextPage;
  final bool hasPreviousPage;
  final String startCursor;
  final String endCursor;

  PageInfo({
    this.hasNextPage,
    this.hasPreviousPage,
    this.startCursor,
    this.endCursor,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) =>
      _$PageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PageInfoToJson(this);
}
