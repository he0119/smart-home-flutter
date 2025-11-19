import 'package:smarthome/core/model/relay.dart';
import 'package:smarthome/storage/model/storage.dart';

Item buildItem({String id = 'item-1', String? name}) => Item(
      id: id,
      name: name ?? 'Item $id',
    );

Storage buildStorage({
  String id = 'storage-1',
  String? name,
  List<Item>? items,
  List<Storage>? children,
}) =>
    Storage(
      id: id,
      name: name ?? 'Storage $id',
      items: items,
      children: children,
    );

PageInfo buildPageInfo({
  bool hasNextPage = false,
  String? endCursor,
}) =>
    PageInfo(
      hasNextPage: hasNextPage,
      endCursor: endCursor,
    );
