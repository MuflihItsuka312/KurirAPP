// lib/pages/home_page.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../services/notification_service.dart';
import 'qr_scanner_page.dart';
import 'login_page.dart';

class CourierHomePage extends StatefulWidget {
  const CourierHomePage({super.key});

  @override
  State<CourierHomePage> createState() => _CourierHomePageState();
}

class _CourierHomePageState extends State<CourierHomePage> {
  String _courierName = '';
  String _courierPlate = '';
  String? _statusText;
  Color _statusColor = Colors.black87;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCourier();
  }

  Future<void> _loadCourier() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('courier_name') ?? '';
    final plate = prefs.getString('courier_plate') ?? '';

    if (!mounted) return;
    if (name.isEmpty || plate.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CourierLoginPage()),
      );
      return;
    }

    setState(() {
      _courierName = name;
      _courierPlate = plate;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('courier_name');
    await prefs.remove('courier_plate');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CourierLoginPage()),
    );
  }

  Future<void> _scanAndDeposit() async {
    final scanStartTime = DateTime.now();
    developer.log('========================================', name: 'KURIR');
    developer.log('Starting QR scan at ${scanStartTime.toIso8601String()}', name: 'SCAN');
    developer.log('========================================', name: 'KURIR');
    
    setState(() {
      _statusText = null;
    });

    // buka scanner
    final token = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );

    final scanEndTime = DateTime.now();
    final scanDuration = scanEndTime.difference(scanStartTime).inMilliseconds;

    if (token == null || token.isEmpty) {
      developer.log('========================================', name: 'KURIR');
      developer.log('CANCELLED after ${scanDuration}ms', name: 'SCAN');
      developer.log('========================================', name: 'KURIR');
      setState(() {
        _statusText = 'Scan dibatalkan.';
        _statusColor = Colors.grey;
      });
      return;
    }

    developer.log('========================================', name: 'KURIR');
    developer.log('SUCCESS in ${scanDuration}ms', name: 'SCAN');
    developer.log('Token: $token', name: 'SCAN');
    developer.log('========================================', name: 'KURIR');

    setState(() {
      _submitting = true;
      _statusText = 'Mengirim ke server...';
      _statusColor = Colors.blueGrey;
    });

    final apiStartTime = DateTime.now();
    developer.log('Sending request to server...', name: 'DEPOSIT');
    developer.log('Plate: $_courierPlate', name: 'DEPOSIT');

    try {
      final resp = await ApiClient.post('/api/courier/deposit', {
        'lockerToken': token,
        'plate': _courierPlate,
      });

      final apiEndTime = DateTime.now();
      final apiDuration = apiEndTime.difference(apiStartTime).inMilliseconds;

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        
        developer.log('========================================', name: 'KURIR');
        developer.log('SUCCESS in ${apiDuration}ms', name: 'DEPOSIT');
        developer.log('Locker: ${data['lockerId']}, Resi: ${data['resi']}', name: 'DEPOSIT');
        developer.log('========================================', name: 'KURIR');
        
        // Show notification
        await NotificationService().showDepositSuccessNotification(
          resi: data['resi'] ?? 'Unknown',
          lockerId: data['lockerId'] ?? 'Unknown',
        );
        
        setState(() {
          _statusText =
              'Berhasil! Locker ${data['lockerId']} akan terbuka untuk resi ${data['resi']}.';
          _statusColor = Colors.green;
        });
      } else {
        final body =
            resp.body.isNotEmpty ? jsonDecode(resp.body) : {'error': ''};
        
        developer.log('========================================', name: 'KURIR');
        developer.log('FAILED in ${apiDuration}ms', name: 'DEPOSIT');
        developer.log('Status: ${resp.statusCode}, Error: ${body['error']}', name: 'DEPOSIT');
        developer.log('========================================', name: 'KURIR');
        
        setState(() {
          _statusText =
              'Gagal titip ke locker (${resp.statusCode}): ${body['error'] ?? 'Unknown error'}';
          _statusColor = Colors.red;
        });
      }
    } catch (e) {
      final apiEndTime = DateTime.now();
      final apiDuration = apiEndTime.difference(apiStartTime).inMilliseconds;
      
      developer.log('========================================', name: 'KURIR');
      developer.log('EXCEPTION after ${apiDuration}ms', name: 'DEPOSIT');
      developer.log('Error: $e', name: 'DEPOSIT');
      developer.log('========================================', name: 'KURIR');
      
      setState(() {
        _statusText = 'Error koneksi: $e';
        _statusColor = Colors.red;
      });
    } finally {
      final totalTime = DateTime.now().difference(scanStartTime).inMilliseconds;
      developer.log('Total operation time: ${totalTime}ms', name: 'DEPOSIT');
      
      setState(() {
        _submitting = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_courierName.isEmpty || _courierPlate.isEmpty) {
      // sementara tampilin loader saat nunggu _loadCourier()
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Locker – Kurir'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $_courierName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Plat: $_courierPlate',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Text(
              'Langkah:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              '1. Dekatkan ke locker yang dituju\n'
              '2. Tekan tombol di bawah\n'
              '3. Scan QR di LCD ESP32\n'
              '4. Locker akan terbuka bila paket untuk plat ini tersedia',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _scanAndDeposit,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(
                    _submitting ? 'Memproses...' : 'Scan QR & Titip Paket',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_statusText != null)
              Text(
                _statusText!,
                style: TextStyle(color: _statusColor, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}
