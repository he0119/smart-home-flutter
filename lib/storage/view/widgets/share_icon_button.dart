import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smarthome/core/model/global_keys.dart';
import 'package:flutter/widget_previews.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class ShareQrIconButton extends StatelessWidget {
  final String name;
  final String data;

  const ShareQrIconButton({super.key, required this.data, required this.name});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '分享',
      child: IconButton(
        tooltip: '分享',
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
              const SnackBar(content: Text('分享成功')),
            );
          } else {
            scaffoldMessengerKey.currentState!.showSnackBar(
              const SnackBar(content: Text('分享失败')),
            );
          }
        },
      ),
    );
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@Preview(
  name: 'ShareQrIconButton',
  group: previewGroupStorage,
  size: Size(120, 80),
)
Widget shareQrIconButtonPreview() => const PreviewFrame(
  width: 120,
  padding: EdgeInsets.zero,
  child: Center(
    child: ShareQrIconButton(
      name: '阳台储物柜',
      data: 'https://smart.example.com/storage/U3RvcmFnZTo1',
    ),
  ),
);
