import 'package:flutter/material.dart';
import '../../core/network/network_engine.dart';

class NetworkScannerApp extends StatefulWidget {
  const NetworkScannerApp({super.key});

  @override
  State<NetworkScannerApp> createState() => _NetworkScannerAppState();
}

class _NetworkScannerAppState extends State<NetworkScannerApp> {
  final TextEditingController _subnetController = TextEditingController(text: '192.168.1');
  final TextEditingController _hostController = TextEditingController(text: '192.168.1.1');
  String _output = '';
  bool _isScanning = false;

  Future<void> _scanNetwork() async {
    setState(() {
      _isScanning = true;
      _output = 'جاري فحص الشبكة...\n';
    });
    
    final hosts = await NetworkEngine.pingSweep(_subnetController.text);
    
    setState(() {
      _output = '✅ تم العثور على ${hosts.length} جهاز:\n';
      for (final host in hosts) {
        _output += '  • $host\n';
      }
      _isScanning = false;
    });
  }

  Future<void> _scanPorts() async {
    setState(() {
      _isScanning = true;
      _output = 'جاري فحص المنافذ...\n';
    });
    
    final ports = [21, 22, 23, 25, 53, 80, 443, 8080];
    final openPorts = await NetworkEngine.scanPorts(_hostController.text, ports);
    
    setState(() {
      _output = '🔓 المنافذ المفتوحة على ${_hostController.text}:\n';
      if (openPorts.isEmpty) {
        _output += '  ❌ لا توجد منافذ مفتوحة\n';
      } else {
        for (final port in openPorts) {
          _output += '  ✅ المنفذ $port مفتوح\n';
        }
      }
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Network Scanner', style: TextStyle(color: Color(0xFF00FF41))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF41)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _subnetController,
              style: const TextStyle(color: Color(0xFF00FF41)),
              decoration: const InputDecoration(
                labelText: 'الشبكة (مثال: 192.168.1)',
                labelStyle: TextStyle(color: Color(0xFF00FF41)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hostController,
              style: const TextStyle(color: Color(0xFF00FF41)),
              decoration: const InputDecoration(
                labelText: 'المضيف (للمنافذ)',
                labelStyle: TextStyle(color: Color(0xFF00FF41)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _scanNetwork,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF41)),
                    child: const Text('فحص الشبكة', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _scanPorts,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF41)),
                    child: const Text('فحص المنافذ', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isScanning) const LinearProgressIndicator(color: Color(0xFF00FF41)),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: const TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
