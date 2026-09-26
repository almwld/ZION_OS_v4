import 'package:flutter/material.dart';

/// Stable destination shown after successful PIN/verification.
/// Intentionally has no Provider, localization, service, or generated-code
/// dependencies so it cannot fail because a dependency is missing.
class PostVerificationScreen extends StatelessWidget {
  const PostVerificationScreen({super.key});

  static const _cyan = Color(0xFF00BCD4);
  static const _teal = Color(0xFF006064);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.25,
              colors: [_teal, Colors.black],
            ),
          ),
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [_cyan, _teal],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _cyan.withOpacity(0.35),
                              blurRadius: 28,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Z',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'ZION OS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'تم التحقق بنجاح',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 34),
                      _buildGrid(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        border: Border(
          bottom: BorderSide(color: _cyan.withOpacity(0.18)),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user, color: _cyan, size: 22),
          SizedBox(width: 10),
          Text(
            'SYSTEM READY',
            style: TextStyle(
              color: _cyan,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          Spacer(),
          Icon(Icons.circle, color: Colors.greenAccent, size: 10),
          SizedBox(width: 6),
          Text(
            'ONLINE',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final items = <_HomeItem>[
      _HomeItem(Icons.dashboard_outlined, 'لوحة النظام'),
      _HomeItem(Icons.terminal, 'الطرفية'),
      _HomeItem(Icons.folder_outlined, 'الملفات'),
      _HomeItem(Icons.settings_outlined, 'الإعدادات'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _showUnavailable(context, item.title),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _cyan.withOpacity(0.18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: _cyan, size: 34),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUnavailable(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title — سيتم تفعيل هذه الوحدة من شاشة النظام.',
          textDirection: TextDirection.rtl,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HomeItem {
  final IconData icon;
  final String title;

  const _HomeItem(this.icon, this.title);
}
