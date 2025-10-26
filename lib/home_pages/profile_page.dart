// profile_page.dart
// A complete Profile page with: avatar change, name/phone/password edit,
// language picker, privacy & terms, contact us, complaints, loyalty points,
// notifications toggle, and consistent styling.

// ignore_for_file: unused_element_parameter, unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Palette
  static const kBlue = Color(0xFF3F7CFF);
  static const kBg = Color(0xFFF4F6F9);

  // Controllers
  final _nameCtr = TextEditingController(text: 'John Doe');
  final _phoneCtr = TextEditingController(text: '+966500000000');
  final _emailCtr = TextEditingController(text: 'john@example.com');

  // Avatar
  final ImagePicker _picker = ImagePicker();
  XFile? _picked;

  // Language
  String _language = 'English';

  // Loyalty points (demo)
  int _points = 420;
  int _nextTierAt = 500;

  // Notifications
  bool _pushEnabled = true;

  @override
  void dispose() {
    _nameCtr.dispose();
    _phoneCtr.dispose();
    _emailCtr.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _picked = x);
  }

  void _changePassword() {
    final oldCtr = TextEditingController();
    final newCtr = TextEditingController();
    final confirmCtr = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: oldCtr,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newCtr,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmCtr,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(backgroundColor: Colors.grey.shade600),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(backgroundColor: kBlue),
            onPressed: () {
              if (newCtr.text.trim().isEmpty || newCtr.text != confirmCtr.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _pickLanguage() async {
    final langs = ['English', 'العربية', 'Français'];
    String tmp = _language;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...langs.map((l) => RadioListTile<String>(
                    value: l,
                    groupValue: tmp,
                    onChanged: (v) => setS(() => tmp = v ?? tmp),
                    title: Text(l),
                  )),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(backgroundColor: Colors.grey.shade600),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() => _language = tmp);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Language set to $_language')),
                        );
                      },
                      style: TextButton.styleFrom(backgroundColor: kBlue),
                      child: const Text('Apply', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openContactForm() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _SimpleFormPage(
      title: 'Contact Us',
      kBlue: kBlue,
      hint: 'How can we help you?',
      success: 'Thanks! We will get back to you soon.',
    )));
  }

  void _openComplaintsForm() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _SimpleFormPage(
      title: 'Complaints',
      kBlue: kBlue,
      hint: 'Describe your issue in detail',
      success: 'Your complaint has been submitted.',
    )));
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_points / _nextTierAt).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile refreshed')),
            ),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            children: [
              // Header card: avatar + quick info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFE9F1FF),
                          backgroundImage: _picked != null ? FileImage(File(_picked!.path)) : null,
                          child: _picked == null
                              ? const Icon(Icons.person_rounded, size: 38, color: Colors.black45)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: _pickAvatar,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: kBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _nameCtr,
                            decoration: const InputDecoration(
                              isDense: true,
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailCtr,
                            readOnly: true,
                            decoration: const InputDecoration(
                              isDense: true,
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.alternate_email),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Contact + password
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Account'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneCtr,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.call_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _changePassword,
                        icon: const Icon(Icons.lock_reset_rounded, color: Colors.white),
                        label: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Language + notifications
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Preferences'),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.language_rounded),
                      title: const Text('Language'),
                      subtitle: Text(_language),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _pickLanguage,
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _pushEnabled,
                      onChanged: (v) => setState(() => _pushEnabled = v),
                      title: const Text('Push Notifications'),
                      secondary: const Icon(Icons.notifications_active_rounded),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Loyalty
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Loyalty'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (_points / _nextTierAt).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE9F1FF),
                            valueColor: const AlwaysStoppedAnimation<Color>(kBlue),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('$_points pts', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('$_points / $_nextTierAt to next reward', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Loyalty details coming soon')),
                          );
                        },
                        icon: const Icon(Icons.card_giftcard_rounded, color: Colors.white),
                        label: const Text('View Rewards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Help / Legal
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Help & Legal'),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _openStaticPage(title: 'Privacy Policy'),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.rule_folder_outlined),
                      title: const Text('Terms of Use'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _openStaticPage(title: 'Terms of Use'),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.support_agent_rounded),
                      title: const Text('Contact Us'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _openContactForm,
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.report_gmailerrorred_rounded),
                      title: const Text('Complaints'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _openComplaintsForm,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Save / Logout
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Persist to backend
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile saved')),
                          );
                        },
                        icon: const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Logout logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged out')),
                          );
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers
  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: child,
      );

  void _openStaticPage({required String title}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _StaticTextPage(
      title: title,
      kBlue: kBlue,
      content: 'This is a placeholder for "$title". Replace with your real content.',
    )));
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
  }
}

class _StaticTextPage extends StatelessWidget {
  final String title;
  final String content;
  final Color kBlue;
  const _StaticTextPage({super.key, required this.title, required this.content, required this.kBlue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(content, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _SimpleFormPage extends StatefulWidget {
  final String title;
  final String hint;
  final String success;
  final Color kBlue;
  const _SimpleFormPage({
    super.key,
    required this.title,
    required this.hint,
    required this.success,
    required this.kBlue,
  });

  @override
  State<_SimpleFormPage> createState() => _SimpleFormPageState();
}

class _SimpleFormPageState extends State<_SimpleFormPage> {
  final _subjectCtr = TextEditingController();
  final _messageCtr = TextEditingController();

  @override
  void dispose() {
    _subjectCtr.dispose();
    _messageCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kBlue = widget.kBlue;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          children: [
            TextField(
              controller: _subjectCtr,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageCtr,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: widget.hint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Send to backend
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.success)));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text('Send', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
