import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'desktop_home.dart';
import 'package:easy_localization/easy_localization.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          _currentDate = "${now.day}/${now.month}/${now.year}";
        });
        _updateDateTime();
      }
    });
  }

  void _unlock() {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    if (provider.validatePin(_pinController.text)) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ZionDesktop()));
    } else {
      setState(() {
        _errorMessage = 'PIN Incorrect';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: isDark ? [const Color(0xFF0A2E38), Colors.black] : [const Color(0xFFE0F7FA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF006064)]),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text("Z", style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(height: 20),
              Text(_currentTime, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF00BCD4))),
              const SizedBox(height: 8),
              Text(_currentDate, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 50),
              Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.5)),
                ),
                child: TextField(
                  controller: _pinController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 24, letterSpacing: 10),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    hintText: "••••",
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                    counterText: "",
                  ),
                  onSubmitted: (_) => _unlock(),
                ),
              ),
              if (_errorMessage.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 15), child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    _buildButton("1"), _buildButton("2"), _buildButton("3"),
                    _buildButton("4"), _buildButton("5"), _buildButton("6"),
                    _buildButton("7"), _buildButton("8"), _buildButton("9"),
                    _buildButton(""), _buildButton("0"), _buildButton("⌫"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String num) {
    return GestureDetector(
      onTap: () {
        if (num == "⌫") {
          if (_pinController.text.isNotEmpty) _pinController.text = _pinController.text.substring(0, _pinController.text.length - 1);
        } else if (num.isNotEmpty && _pinController.text.length < 4) {
          _pinController.text += num;
          if (_pinController.text.length == 4) _unlock();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Center(child: Text(num, style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 28, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
