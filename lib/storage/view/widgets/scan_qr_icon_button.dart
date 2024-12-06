import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smarthome/core/model/grobal_keys.dart';
import 'package:smarthome/routers/delegate.dart';
import 'package:smarthome/storage/storage.dart';

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

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  bool jumped = false;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('二维码')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  jumped = false;
                });
                if (!kIsWeb) {
                  await controller?.resumeCamera();
                }
              },
              child: _buildQrView(context),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(jumped ? '请单击屏幕再次扫描' : '请扫描二维码'),
                if (!kIsWeb)
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      child: FutureBuilder(
                        future: controller?.getFlashStatus(),
                        builder: (context, snapshot) {
                          return Text(
                              snapshot.data ?? false ? '关闭闪光灯' : '打开闪光灯');
                        },
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (jumped) {
        return;
      }
      var storageId = scanData.code;

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
          jumped = true;
        });
        // TODO: 弄清楚这里是什么情况，没看懂哪里来的 async gap。
        // ignore: use_build_context_synchronously
        MyRouterDelegate.of(context)
            .push(StorageDetailPage(storageId: storageId));
        // 只有安卓设备支持暂停相机
        if (!kIsWeb && Platform.isAndroid) {
          await controller.pauseCamera();
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(content: Text('没有相机权限')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
