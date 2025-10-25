import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/home_pages/home_page.dart';
import 'package:flutter_application_vallet_cars/welcome_and_sign_pages/forget_password.dart';

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignAndRejisterPage(),
  ),
);

class SignAndRejisterPage extends StatefulWidget {
  const SignAndRejisterPage({super.key});
  @override
  State<SignAndRejisterPage> createState() => _SignAndRejisterPageState();
}

class _SignAndRejisterPageState extends State<SignAndRejisterPage> {
  // تحكم في التبويب
  bool _isSignIn = true;

  // كنترولرز Sign In
  final _emailIn = TextEditingController();
  final _passIn = TextEditingController();
  bool _hideIn = true;
  bool _emailInInvalid = false;
  bool _remember = true;

  // كنترولرز Register (تقدر تغيّرهم لاحقًا حسب شكلك)
  final _nameUp = TextEditingController();
  final _emailUp = TextEditingController();
  final _passUp = TextEditingController();
  final _confirmUp = TextEditingController();
  bool _hideUp = true;
  bool _hideUp2 = true;

  static const Color kBlue = Color(0xFF3F7CFF);
  static const Color kFieldBorder = Color(0xFFE5E7EB);
  static const Color kGrey = Color(0xFF77839A);

  @override
  void dispose() {
    _emailIn.dispose();
    _passIn.dispose();
    _nameUp.dispose();
    _emailUp.dispose();
    _passUp.dispose();
    _confirmUp.dispose();
    super.dispose();
  }

  void _validateEmailIn(String v) {
    final ok = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v.trim());
    setState(() => _emailInInvalid = v.isNotEmpty && !ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlue, // الهيدر الأزرق
      body: Stack(
        children: [
          Container(height: 220, color: kBlue),
          Align(
            alignment: const Alignment(
              0,
              0.10,
            ), // -0.10 ترفعه شويه لفوق (عدّلها بين -0.25 و 0 حسب ما تحب)
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شعار بسيط + اسم
                    Row(
                      children: const [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.directions_car_rounded,
                            size: 18,
                            color: kBlue,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ValletCar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isSignIn ? 'Hi, Welcome Back' : 'Create Your Account',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== تبويب Sign In / Register (segmented) =====
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _SegmentChip(
                            text: 'Sign In',
                            selected: _isSignIn,
                            onTap: () => setState(() => _isSignIn = true),
                          ),
                          _SegmentChip(
                            text: 'Register',
                            selected: !_isSignIn,
                            onTap: () => setState(() => _isSignIn = false),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ===== المحتوى يتبدّل بدون تغيير الشاشة =====
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _isSignIn ? _buildSignIn() : _buildRegister(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================== SIGN IN ===================
  Widget _buildSignIn() {
    return Column(
      key: const ValueKey('signin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_emailInInvalid)
          const _ErrorBanner(text: 'Your email is incorrect'),
        if (_emailInInvalid) const SizedBox(height: 8),

        const _Label('Email'),
        _PillField(
          controller: _emailIn,
          hint: 'name@email.com',
          icon: Icons.mail_outline_rounded,
          keyboard: TextInputType.emailAddress,
          onChanged: _validateEmailIn,
          errorBorder: _emailInInvalid,
        ),
        const SizedBox(height: 12),

        const _Label('Password'),
        _PillField(
          controller: _passIn,
          hint: '********',
          icon: Icons.lock_outline_rounded,
          obscure: _hideIn,
          trailing: IconButton(
            onPressed: () => setState(() => _hideIn = !_hideIn),
            icon: Icon(
              _hideIn
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Checkbox(
              value: _remember,
              onChanged: (v) => setState(() => _remember = v ?? true),
              activeColor: kBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const Text('Remember me'),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: kBlue, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Login
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlue,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Divider
        Row(
          children: const [
            Expanded(child: Divider(color: Color(0xFFE6EAF0))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Or Sign in with', style: TextStyle(color: kGrey)),
            ),
            Expanded(child: Divider(color: Color(0xFFE6EAF0))),
          ],
        ),
        const SizedBox(height: 14),

        // زر Google كبير (بدل زرين)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              /* TODO: Google Sign-In */
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE6EAF0)),
              backgroundColor: const Color(0xFFF9FAFB),
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/img/google1.webp', width: 22, height: 22),
                const SizedBox(width: 10),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =================== REGISTER (جاهزة لتعديلك) ===================
  Widget _buildRegister() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Full Name'),
        _PillField(
          controller: _nameUp,
          hint: 'John Doe',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),

        const _Label('Email'),
        _PillField(
          controller: _emailUp,
          hint: 'name@email.com',
          icon: Icons.mail_outline_rounded,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),

        const _Label('Password'),
        _PillField(
          controller: _passUp,
          hint: '********',
          icon: Icons.lock_outline_rounded,
          obscure: _hideUp,
          trailing: IconButton(
            onPressed: () => setState(() => _hideUp = !_hideUp),
            icon: Icon(
              _hideUp
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 12),

        const _Label('Confirm Password'),
        _PillField(
          controller: _confirmUp,
          hint: '********',
          icon: Icons.lock_outline_rounded,
          obscure: _hideUp2,
          trailing: IconButton(
            onPressed: () => setState(() => _hideUp2 = !_hideUp2),
            icon: Icon(
              _hideUp2
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlue,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // (اختياري) سطر: لديك حساب؟ Sign In
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account? "),
            TextButton(
              onPressed: () => setState(() => _isSignIn = true),
              child: const Text(
                'Sign In',
                style: TextStyle(color: kBlue, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =================== Widgets مساعدة ===================

class _SegmentChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3F7CFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _PillField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboard;
  final bool errorBorder;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;

  const _PillField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboard,
    this.errorBorder = false,
    this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = errorBorder
        ? const Color(0xFFFFD4D4)
        : _SignAndRejisterPageState.kFieldBorder;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              obscureText: obscure,
              keyboardType: keyboard,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD6D6)),
      ),
      child: Row(
        children: const [
          Icon(Icons.error_outline, color: Color(0xFFD33A2C)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your email is incorrect',
              style: TextStyle(
                color: Color(0xFFD33A2C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
