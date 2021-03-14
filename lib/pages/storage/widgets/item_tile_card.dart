import 'package:flutter/material.dart';

class ItemTileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ItemTileCard({
    Key key,
    @required this.title,
    @required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(2),
      child: Container(
        height: 72,
        alignment: Alignment.center,
        child: ListTile(
          title: Text(title),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
