// lib/pages/login_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import 'home_page.dart';

class CourierLoginPage extends StatefulWidget {
  const CourierLoginPage({Key? key}) : super(key: key);

  @override
  State<CourierLoginPage> createState() => _CourierLoginPageState();
}

class _CourierLoginPageState extends State<CourierLoginPage> {
  final _nameCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final name = _nameCtrl.text.trim();
    final plate = _plateCtrl.text.trim().toUpperCase();

    if (name.isEmpty || plate.isEmpty) {
      setState(() {
        _error = 'Nama dan plat wajib diisi.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resp = await ApiClient.post('/api/courier/login', {
        'name': name,
        'plate': plate,
      });

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('courier_name', data['courierName'] ?? name);
        await prefs.setString('courier_plate', data['plate'] ?? plate);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CourierHomePage()),
        );
      } else {
        final body =
            resp.body.isNotEmpty ? jsonDecode(resp.body) : {'error': ''};
        setState(() {
          _error = body['error'] ?? 'Login gagal (${resp.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error koneksi: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Kurir')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Kurir',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _plateCtrl,
              decoration: const InputDecoration(
                labelText: 'Plat Nomor (mis: B1234CD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
