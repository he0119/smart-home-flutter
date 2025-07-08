import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smarthome/core/model/grobal_keys.dart';

class ShareQrIconButton extends StatelessWidget {
  final String name;
  final String data;

  const ShareQrIconButton({super.key, required this.data, required this.name});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '分享',
      child: IconButton(
        icon: const Icon(Icons.share),
        onPressed: () async {
          final painter = QrPainter(
            data: data,
            version: QrVersions.auto,
            gapless: true,
          );
          final imageData = await painter.toImageData(600);
          final imageBytes = imageData?.buffer.asUint8List();
          // share image
          if (imageBytes == null) {
            return;
          }
          final params = ShareParams(
            text: '二维码',
            files: [XFile.fromData(imageBytes, mimeType: 'image/png')],
            fileNameOverrides: ['$name.png'],
          );
          final shareResult = await SharePlus.instance.share(params);
          if (shareResult.status == ShareResultStatus.success) {
            scaffoldMessengerKey.currentState!.showSnackBar(
              const SnackBar(
                content: Text('分享成功'),
              ),
            );
          } else {
            scaffoldMessengerKey.currentState!.showSnackBar(
              const SnackBar(
                content: Text('分享失败'),
              ),
            );
          }
        },
      ),
    );
  }
}
