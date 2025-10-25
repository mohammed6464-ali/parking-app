import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/welcome_and_sign_pages/signup_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const Color kBlue = Color(0xFF3F7CFF);
  static const Color kFieldBorder = Color(0xFFE5E7EB);

  final _email = TextEditingController();
  bool _invalid = false;
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  Future<void> _onContinue() async {
    final email = _email.text.trim();
    final valid = _isValidEmail(email);
    setState(() => _invalid = !valid);
    if (!valid) return;

    setState(() => _sending = true);

    try {
      // TODO (اختياري): فعّل الإرسال عبر Firebase Auth
      // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link will be sent to $email'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // رجوع/أو انتقل لصفحة "Check your email"
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset link: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط علوي (رجوع + لوجو نصي بسيط)
              Row(
                children: [
                  IconButton(
                    onPressed: () {Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SignAndRejisterPage()),
                );},
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black12.withOpacity(.06),
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.directions_car_rounded,
                      size: 18,
                      color: kBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ValletCar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // العنوان والنص التوضيحي
              const Center(
                child: Text(
                  'Create New Password',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Enter your email to receive a password\nreset link',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
              ),
              const SizedBox(height: 28),

              // الليبل + الحقل
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _invalid ? const Color(0xFFFFD4D4) : kFieldBorder,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      color: _invalid
                          ? const Color(0xFFD33A2C)
                          : Colors.black54,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (v) => setState(() => _invalid = false),
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_invalid) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD6D6)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Color(0xFFD33A2C)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please enter a valid email address',
                          style: TextStyle(
                            color: Color(0xFFD33A2C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // زر المتابعة
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _sending ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
