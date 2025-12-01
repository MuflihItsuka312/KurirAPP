// lib/pages/courier_register_page.dart

import 'package:flutter/material.dart';
import '../services/api_client.dart';

class CourierRegisterPage extends StatefulWidget {
  const CourierRegisterPage({Key? key}) : super(key: key);

  @override
  State<CourierRegisterPage> createState() => _CourierRegisterPageState();
}

class _CourierRegisterPageState extends State<CourierRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedCompany;
  bool _isLoading = false;

  final List<Map<String, String>> _companies = [
    {'value': 'anteraja', 'label': 'AnterAja'},
    {'value': 'jne', 'label': 'JNE'},
    {'value': 'jnt', 'label': 'J&T Express'},
    {'value': 'sicepat', 'label': 'SiCepat'},
    {'value': 'ninja', 'label': 'Ninja Xpress'},
    {'value': 'pos', 'label': 'POS Indonesia'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiClient.registerCourier(
        name: _nameController.text.trim(),
        company: _selectedCompany!,
        plate: _plateController.text.trim().toUpperCase(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Registrasi Berhasil!'),
              ],
            ),
            content: Text(
              '${result['message']}\n\n'
              'Nama: ${result['data']['name']}\n'
              'Perusahaan: ${result['data']['company'].toString().toUpperCase()}\n'
              'Plat: ${result['data']['plate']}\n\n'
              'Silakan login dengan nama lengkap dan password Anda.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to login
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Kurir'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Icon(Icons.local_shipping, size: 80, color: Colors.blue),
              const SizedBox(height: 10),
              const Text(
                'Daftar sebagai Kurir',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Contoh: John Doe',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap wajib diisi';
                  }
                  if (value.length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Company Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCompany,
                decoration: InputDecoration(
                  labelText: 'Perusahaan Ekspedisi',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _companies.map((company) {
                  return DropdownMenuItem(
                    value: company['value'],
                    child: Text(company['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCompany = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih perusahaan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Plate Field
              TextFormField(
                controller: _plateController,
                decoration: InputDecoration(
                  labelText: 'Plat Kendaraan',
                  prefixIcon: const Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'B 1234 CD',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Plat kendaraan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'No. HP (Opsional)',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: '08xxxxxxxxxx',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'DAFTAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 15),

              // Back to Login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Sudah punya akun? Login di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
