import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smarthome/storage/model/models.dart';

class StorageQrPage extends StatelessWidget {
  final Storage storage;

  const StorageQrPage({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二维码'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: storage.id,
              version: QrVersions.auto,
              size: 200.0,
            ),
            Text('ID: ${storage.id}'),
            Text('名称: ${storage.name}'),
          ],
        ),
      ),
    );
  }
}
