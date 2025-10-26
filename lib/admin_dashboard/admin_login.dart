// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/admin_dashboard/admin_home_page.dart';
// import 'dashboard_page.dart'; // Uncomment when DashboardPage is ready

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  static const kBlue = Color(0xFF3F7CFF);
  static const kBg = Color(0xFFF4F6F9);

  final _formKey = GlobalKey<FormState>();
  final _emailCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  final _pinCtr = TextEditingController();

  bool _hidePassword = true;
  bool _hidePin = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtr.dispose();
    _passwordCtr.dispose();
    _pinCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Container(height: 400, color: kBlue),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header with Icon logo and App Name
                      Column(
                        children: const [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              color: kBlue,
                              size: 50,
                            ),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Vallet Cars',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Admin Login',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(
                                controller: _emailCtr,
                                label: 'Email',
                                icon: Icons.alternate_email,
                                validator: _emailValidator,
                              ),
                              const SizedBox(height: 14),
                              _buildTextField(
                                controller: _passwordCtr,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscureText: _hidePassword,
                                onToggleVisibility: () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                                validator: _passwordValidator,
                              ),
                              const SizedBox(height: 14),
                              _buildTextField(
                                controller: _pinCtr,
                                label: 'Secret PIN',
                                icon: Icons.pin_outlined,
                                keyboardType: TextInputType.number,
                                isPassword: true,
                                obscureText: _hidePin,
                                onToggleVisibility: () =>
                                    setState(() => _hidePin = !_hidePin),
                                validator: _pinValidator,
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DashboardPage(),
                                      ),
                                    );
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      Opacity(
                        opacity: 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Use your admin credentials and secret PIN',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        isDense: true,
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null,
      ),
    );
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final ok = await _demoAuthenticate(
        email: _emailCtr.text.trim(),
        password: _passwordCtr.text,
        pin: _pinCtr.text,
      );
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Welcome back, Admin!')));
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials or PIN')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _demoAuthenticate({
    required String email,
    required String password,
    required String pin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return email == 'admin@valletcars.com' &&
        password == 'Admin@123' &&
        pin == '123456';
  }

  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final emailRx = RegExp(r'^[\\w\\.-]+@[\\w\\.-]+\\.[a-zA-Z]{2,}');
    if (!emailRx.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  String? _pinValidator(String? v) {
    if (v == null || v.isEmpty) return 'PIN is required';
    if (!RegExp(r'^\\d{4,8}\$').hasMatch(v)) return 'PIN must be 4–8 digits';
    return null;
  }
}
