import 'package:flutter/material.dart';
import '../../core/arsenal/zion_wifi_advanced.dart';

class ZionWiFiPanel extends StatefulWidget {
  const ZionWiFiPanel({super.key});

  @override
  State<ZionWiFiPanel> createState() => _ZionWiFiPanelState();
}

class _ZionWiFiPanelState extends State<ZionWiFiPanel> {
  final ZionWiFi _wifi = ZionWiFi();
  List<WiFiNetwork> _networks = [];
  List<HiddenNetwork> _hiddenNetworks = [];
  bool _isScanning = false;
  bool _isAttacking = false;
  String _attackLog = '';
  String _selectedTarget = '';
  
  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }
  
  Future<void> _scanNetworks() async {
    setState(() => _isScanning = true);
    _networks = await _wifi.scanAllNetworks();
    _hiddenNetworks = await _wifi.discoverHiddenNetworks();
    setState(() => _isScanning = false);
  }
  
  Future<void> _attackNetwork(String bssid) async {
    setState(() {
      _isAttacking = true;
      _selectedTarget = bssid;
      _attackLog = '🎯 Starting attack on $bssid...\n';
    });
    
    final result = await _wifi.fullAttack(bssid);
    
    setState(() {
      if (result.success) {
        _attackLog += '✅ SUCCESS!\n';
        _attackLog += '🔑 Password: ${result.password}\n';
        _attackLog += '⏱️ Duration: ${result.duration.inSeconds} seconds\n';
      } else {
        _attackLog += '❌ FAILED!\n';
        _attackLog += 'No password found for $bssid\n';
      }
      _isAttacking = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ZionWiFi - Wireless Attack Platform'),
        backgroundColor: Colors.deepPurple.shade900,
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.hourglass_empty : Icons.refresh),
            onPressed: _isScanning ? null : _scanNetworks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Hidden Networks Section
          if (_hiddenNetworks.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🕵️ HIDDEN NETWORKS DISCOVERED',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._hiddenNetworks.map((n) => ListTile(
                    leading: const Icon(Icons.wifi_lock, color: Colors.red),
                    title: Text('Real: ${n.realSSID}', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Hidden as: ${n.hiddenSSID} | ${n.bssid}', style: TextStyle(color: Colors.grey)),
                    trailing: Text('${n.signalStrength} dBm', style: const TextStyle(color: Colors.yellow)),
                  )),
                ],
              ),
            ),
          
          // Networks List
          Expanded(
            child: _networks.isEmpty && !_isScanning
                ? const Center(child: Text('No networks found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _networks.length,
                    itemBuilder: (context, index) {
                      final network = _networks[index];
                      final isAttacking = _isAttacking && _selectedTarget == network.bssid;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isAttacking ? Colors.orange : Colors.grey.shade700,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            _getSecurityIcon(network.security),
                            color: _getSecurityColor(network.security),
                          ),
                          title: Text(
                            network.ssid.isNotEmpty ? network.ssid : '<Hidden>',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${network.bssid} | ${network.security} | CH ${network.channel}',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${network.signalStrength} dBm',
                                style: TextStyle(color: _getSignalColor(network.signalStrength)),
                              ),
                              if (network.isHidden)
                                const Icon(Icons.visibility_off, size: 16, color: Colors.red),
                            ],
                          ),
                          onTap: () => _showAttackDialog(network),
                        ),
                      );
                    },
                  ),
          ),
          
          // Attack Log
          if (_attackLog.isNotEmpty)
            Container(
              height: 150,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📡 ATTACK LOG', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _attackLog,
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _isAttacking
          ? const FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.orange,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: _scanNetworks,
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.wifi_find),
            ),
    );
  }
  
  void _showAttackDialog(WiFiNetwork network) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Attack ${network.ssid}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BSSID: ${network.bssid}', style: const TextStyle(color: Colors.grey)),
            Text('Security: ${network.security}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('This will attempt:', style: TextStyle(color: Colors.white)),
            const Text('• WPS PIN attack', style: TextStyle(color: Colors.yellow)),
            const Text('• PMKID capture & crack', style: TextStyle(color: Colors.yellow)),
            const Text('• Deauth + Handshake capture', style: TextStyle(color: Colors.yellow)),
            const SizedBox(height: 16),
            const Text('⚠️ This may take several minutes', style: TextStyle(color: Colors.orange)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _attackNetwork(network.bssid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('START ATTACK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  IconData _getSecurityIcon(String security) {
    if (security.contains('WPA3')) return Icons.security;
    if (security.contains('WPA2')) return Icons.wifi_protected_setup;
    if (security.contains('WEP')) return Icons.warning;
    return Icons.wifi;
  }
  
  Color _getSecurityColor(String security) {
    if (security.contains('WPA3')) return Colors.green;
    if (security.contains('WPA2')) return Colors.orange;
    if (security.contains('WEP')) return Colors.red;
    return Colors.blue;
  }
  
  Color _getSignalColor(int signal) {
    if (signal > -50) return Colors.green;
    if (signal > -70) return Colors.yellow;
    return Colors.red;
  }
}
