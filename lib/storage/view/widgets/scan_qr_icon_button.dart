import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/widgets/app_preview.dart';
import 'package:smarthome/widgets/preview_frame.dart';

class ScanQRIconButton extends StatelessWidget {
  const ScanQRIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '扫描二维码',
      icon: const Icon(Icons.qr_code),
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ScanQRPage()));
      },
    );
  }
}

/// Button widget for analyze image function
class ScannerErrorWidget extends StatelessWidget {
  /// Construct a new [ScannerErrorWidget] instance.
  const ScannerErrorWidget({required this.error, super.key});

  /// Error to display
  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              error.errorCode.message,
              style: const TextStyle(color: Colors.white),
            ),
            if (error.errorDetails?.message case final String message)
              Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Widget to display scanned barcodes.
class ScannedBarcodeLabel extends StatelessWidget {
  /// Construct a new [ScannedBarcodeLabel] instance.
  const ScannedBarcodeLabel({required this.barcodes, super.key});

  /// Barcode stream for scanned barcodes to display
  final Stream<BarcodeCapture> barcodes;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: barcodes,
      builder: (context, snapshot) {
        final List<Barcode> scannedBarcodes = snapshot.data?.barcodes ?? [];

        final String values = scannedBarcodes
            .map((e) => e.displayValue)
            .join('\n');

        if (scannedBarcodes.isEmpty) {
          return const Text(
            '请扫描二维码',
            overflow: .fade,
            style: TextStyle(color: Colors.white),
          );
        }

        return Text(
          values.isEmpty ? 'No display value.' : values,
          overflow: .fade,
          style: const TextStyle(color: Colors.white),
        );
      },
    );
  }
}

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  MobileScannerController? controller;

  bool jumpedToStorageDetail = false;

  // A scan window does work on web, but not the overlay to preview the scan
  // window. This is why we disable it here for web examples.
  bool useScanWindow = !kIsWeb;

  BoxFit boxFit = BoxFit.contain;

  MobileScannerController initController() =>
      MobileScannerController(autoStart: true, autoZoom: true);

  @override
  void initState() {
    super.initState();
    controller = initController();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller?.dispose();
    controller = null;
  }

  @override
  Widget build(BuildContext context) {
    late final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(const Offset(0, -100)),
      width: 300,
      height: 200,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('二维码')),
      body: Stack(
        children: [
          MobileScanner(
            // useAppLifecycleState: false, // Only set to false if you want
            // to handle lifecycle changes yourself
            scanWindow: useScanWindow ? scanWindow : null,
            controller: controller,
            errorBuilder: (context, error) {
              return ScannerErrorWidget(error: error);
            },
            fit: boxFit,
            onDetect: (result) async {
              // 如果已经跳转到详情页，则不再处理扫描结果
              if (jumpedToStorageDetail) {
                return;
              }

              var storageId = result.barcodes.first.rawValue;

              if (storageId == null) {
                return;
              }

              // 从网址中提取 storageId
              // https://smart.hehome.xyz/storage/U3RvcmFnZTo1
              if (storageId.startsWith('http')) {
                final url = Uri.parse(storageId);
                storageId = url.pathSegments.last;
              }

              if (validateStorageId(storageId)) {
                setState(() {
                  jumpedToStorageDetail = true;
                });

                context.goStorageDetail(storageId);

                await controller?.stop();
              }
            },
          ),
          // The scanWindow is not supported on the web.
          if (useScanWindow)
            ScanWindowOverlay(scanWindow: scanWindow, controller: controller!),
        ],
      ),
    );
  }

  bool validateStorageId(String id) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    try {
      final decoded = stringToBase64.decode(id);
      return decoded.startsWith('Storage:');
    } catch (e) {
      return false;
    }
  }
}

/// 开发时在 IDE 里直接看效果，不依赖后端数据。
@AppPreview(
  name: 'ScanQRIconButton',
  group: previewGroupStorage,
  size: Size(120, 80),
)
Widget scanQrIconButtonPreview() => const PreviewFrame(
  width: 120,
  padding: EdgeInsets.zero,
  child: Center(child: ScanQRIconButton()),
);

@AppPreview(
  name: 'ScannerErrorWidget',
  group: previewGroupStorage,
  size: Size(360, 240),
)
Widget scannerErrorWidgetPreview() => const PreviewFrame(
  width: 360,
  padding: EdgeInsets.zero,
  child: ScannerErrorWidget(
    error: MobileScannerException(
      errorCode: MobileScannerErrorCode.permissionDenied,
      errorDetails: MobileScannerErrorDetails(message: '用户拒绝了相机权限'),
    ),
  ),
);

@AppPreview(
  name: 'ScannedBarcodeLabel',
  group: previewGroupStorage,
  size: Size(360, 200),
)
Widget scannedBarcodeLabelPreview() => PreviewFrame(
  width: 360,
  padding: EdgeInsets.zero,
  child: Builder(
    builder: (BuildContext context) => ColoredBox(
      // 这个组件本来就盖在相机画面上，用遮罩色当底才看得见白字
      color: Theme.of(context).colorScheme.scrim,
      child: Center(
        child: ScannedBarcodeLabel(
          barcodes: Stream<BarcodeCapture>.value(
            const BarcodeCapture(
              barcodes: <Barcode>[
                Barcode(
                  rawValue: 'https://smart.example.com/storage/U3RvcmFnZTo1',
                  displayValue: 'U3RvcmFnZTo1',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
