// lib/pages/home_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import 'qr_scanner_page.dart';
import 'login_page.dart';

class CourierHomePage extends StatefulWidget {
  const CourierHomePage({Key? key}) : super(key: key);

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
    setState(() {
      _statusText = null;
    });

    // buka scanner
    final token = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );

    if (token == null || token.isEmpty) {
      setState(() {
        _statusText = 'Scan dibatalkan.';
        _statusColor = Colors.grey;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _statusText = 'Mengirim ke server...';
      _statusColor = Colors.blueGrey;
    });

    try {
      final resp = await ApiClient.post('/api/courier/deposit', {
        'lockerToken': token,
        'plate': _courierPlate,
      });

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _statusText =
              'Berhasil! Locker ${data['lockerId']} akan terbuka untuk resi ${data['resi']}.';
          _statusColor = Colors.green;
        });
      } else {
        final body =
            resp.body.isNotEmpty ? jsonDecode(resp.body) : {'error': ''};
        setState(() {
          _statusText =
              'Gagal titip ke locker (${resp.statusCode}): ${body['error'] ?? 'Unknown error'}';
          _statusColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'Error koneksi: $e';
        _statusColor = Colors.red;
      });
    } finally {
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
