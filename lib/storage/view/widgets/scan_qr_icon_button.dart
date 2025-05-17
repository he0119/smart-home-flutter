import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRIconButton extends StatelessWidget {
  const ScanQRIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '扫描二维码',
      child: IconButton(
        icon: const Icon(Icons.qr_code),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ScanQRPage(),
            ),
          );
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

        final String values =
            scannedBarcodes.map((e) => e.displayValue).join('\n');

        if (scannedBarcodes.isEmpty) {
          return const Text(
            'Scan something!',
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

  bool jumped = false;

  MobileScannerController? controller;
  // A scan window does work on web, but not the overlay to preview the scan
  // window. This is why we disable it here for web examples.
  bool useScanWindow = !kIsWeb;

  bool autoZoom = false;
  bool invertImage = false;
  bool returnImage = false;

  Size desiredCameraResolution = const Size(1920, 1080);
  DetectionSpeed detectionSpeed = DetectionSpeed.unrestricted;
  int detectionTimeoutMs = 1000;

  bool useBarcodeOverlay = true;
  BoxFit boxFit = BoxFit.contain;
  bool enableLifecycle = false;

  /// Hides the MobileScanner widget while the MobileScannerController is
  /// rebuilding
  bool hideMobileScannerWidget = false;

  List<BarcodeFormat> selectedFormats = [];

  MobileScannerController initController() => MobileScannerController(
        autoStart: false,
        cameraResolution: desiredCameraResolution,
        detectionSpeed: detectionSpeed,
        detectionTimeoutMs: detectionTimeoutMs,
        formats: selectedFormats,
        returnImage: returnImage,
        // torchEnabled: true,
        invertImage: invertImage,
        autoZoom: autoZoom,
      );

  @override
  void initState() {
    super.initState();
    controller = initController();
    unawaited(controller!.start());
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
      body: controller == null || hideMobileScannerWidget
          ? const Placeholder()
          : Stack(
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
                ),
                if (useBarcodeOverlay)
                  BarcodeOverlay(controller: controller!, boxFit: boxFit),
                // The scanWindow is not supported on the web.
                if (useScanWindow)
                  ScanWindowOverlay(
                    scanWindow: scanWindow,
                    controller: controller!,
                  ),
                if (returnImage)
                  Align(
                    alignment: Alignment.topRight,
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: StreamBuilder<BarcodeCapture>(
                          stream: controller!.barcodes,
                          builder: (context, snapshot) {
                            final BarcodeCapture? barcode = snapshot.data;

                            if (barcode == null) {
                              return const Center(
                                child: Text(
                                  'Your scanned barcode will appear here',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            final Uint8List? barcodeImage = barcode.image;

                            if (barcodeImage == null) {
                              return const Center(
                                child: Text('No image for this barcode.'),
                              );
                            }

                            return Image.memory(
                              barcodeImage,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    'Could not decode image bytes. $error',
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    height: 200,
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ScannedBarcodeLabel(
                            barcodes: controller!.barcodes,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
