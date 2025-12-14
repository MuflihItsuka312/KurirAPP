// lib/pages/qr_scanner_page.dart
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    developer.log('QR Scanner page opened', name: 'SCANNER');
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Locker')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_done) return;
              final barcode = capture.barcodes.first;
              final value = barcode.rawValue;
              developer.log('QR Detected: $value', name: 'SCANNER');
              if (value != null && value.isNotEmpty) {
                _done = true;
                developer.log('Returning QR value: $value', name: 'SCANNER');
                Navigator.pop(context, value);
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(12),
              child: const Text(
                'Arahkan kamera ke QR di LCD ESP32',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
