import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:smart_home/blocs/storage/storage_home/storage_home_bloc.dart';
import 'package:smart_home/models/models.dart';

class StorageHomePage extends StatelessWidget {
  const StorageHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StorageHomeBloc()..add(StorageHomeStarted()),
      child: _StorageHomePage(),
    );
  }
}

class _StorageHomePage extends StatelessWidget {
  const _StorageHomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StorageHomeBloc, StorageHomeState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        if (state is StorageHomeInProgress) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is StorageHomeError) {
          return Center(child: Text(state.message));
        }
        if (state is StorageHomeSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<StorageHomeBloc>(context)
                  .add(StorageHomeRefreshed());
            },
            child: CustomScrollView(
              slivers: <Widget>[
                buildExpiredItemList(context, state.expiredItems),
                buildNearExpiredItemList(context, state.nearExpiredItems),
                buildRecentlyUpdatedItems(context, state.recentlyUpdatedItems),
                buildRecentlyAddedItems(context, state.recentlyAddedItems),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  SliverStickyHeader buildExpiredItemList(
      BuildContext context, List<Item> items) {
    return SliverStickyHeader(
      header: Container(
        height: 60.0,
        color: Colors.lightBlue,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          '过期物品',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final difference =
                DateTime.now().difference(items[index].expirationDate).inDays;
            final text = RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: items[index].name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: difference == 0
                        ? '（刚过期）'
                        : '（过期${difference.toString()}天）',
                  ),
                ],
              ),
            );
            return ListTile(
              title: text,
              subtitle: Text(''),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  SliverStickyHeader buildNearExpiredItemList(
      BuildContext context, List<Item> items) {
    return SliverStickyHeader(
      header: Container(
        height: 60.0,
        color: Colors.lightBlue,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          '即将过期',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final difference =
                items[index].expirationDate.difference(DateTime.now()).inDays;

            final text = RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: items[index].name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: difference == 0
                        ? '（不到1天）'
                        : '（还有${difference.toString()}天）',
                  ),
                ],
              ),
            );
            return ListTile(
              title: text,
              subtitle: Text(''),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  SliverStickyHeader buildRecentlyAddedItems(
      BuildContext context, List<Item> items) {
    return SliverStickyHeader(
      header: Container(
        height: 60.0,
        color: Colors.lightBlue,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          '最近添加',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final difference =
                DateTime.now().difference(items[index].dateAdded).inDays;
            final text = RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: items[index].name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: difference == 0
                        ? '（今天）'
                        : '（${difference.toString()}天前）',
                  ),
                ],
              ),
            );
            return ListTile(
              title: text,
              subtitle: Text(items[index].description ?? ''),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  SliverStickyHeader buildRecentlyUpdatedItems(
      BuildContext context, List<Item> items) {
    return SliverStickyHeader(
      header: Container(
        height: 60.0,
        color: Colors.lightBlue,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          '最近更新',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final difference =
                DateTime.now().difference(items[index].updateDate).inDays;
            final text = RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: items[index].name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: difference == 0
                        ? '（今天）'
                        : '（${difference.toString()}天前）',
                  ),
                ],
              ),
            );
            return ListTile(
              title: text,
              subtitle: Text(items[index].description ?? ''),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
