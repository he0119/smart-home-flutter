import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/view/storage_datail_page.dart';

class ScanQRIconButton extends StatelessWidget {
  const ScanQRIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '扫描二维码',
      child: IconButton(
        icon: const Icon(Icons.qr_code),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ScanQRPage()));
        },
      ),
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
          mainAxisSize: MainAxisSize.min,
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
            overflow: TextOverflow.fade,
            style: TextStyle(color: Colors.white),
          );
        }

        return Text(
          values.isEmpty ? 'No display value.' : values,
          overflow: TextOverflow.fade,
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

                MyRouterDelegate.of(
                  context,
                ).push(StorageDetailPage(storageId: storageId));

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
