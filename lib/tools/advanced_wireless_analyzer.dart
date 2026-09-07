import 'dart:io';
import 'package:flutter/services.dart';

/// Defensive Wi-Fi inspection. Results are obtained from Android's Wi-Fi
/// framework; no fabricated networks or password-cracking simulations are used.
class AdvancedWirelessAnalyzer {
  static const MethodChannel _channel = MethodChannel('zion/system');

  static Future<List<Map<String, dynamic>>> fullScan() async {
    if (!Platform.isAndroid) return <Map<String, dynamic>>[];

    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('scanWifi');
      final networks = (raw ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      for (final network in networks) {
        network['security_analysis'] = _analyzeSecurity(network);
      }
      return networks;
    } on PlatformException {
      // The UI should surface the permission/platform error instead of showing
      // fake data. An empty list is intentionally returned for compatibility.
      return <Map<String, dynamic>>[];
    }
  }

  static Map<String, dynamic> _analyzeSecurity(Map<String, dynamic> network) {
    final caps = (network['capabilities']?.toString() ?? '').toUpperCase();
    final analysis = <String, dynamic>{
      'encryption': 'Unknown',
      'wps_enabled': caps.contains('WPS'),
      'vulnerable': false,
      'risks': <String>[],
      'recommendations': <String>[],
    };

    if (caps.contains('WPA3')) {
      analysis['encryption'] = 'WPA3';
      analysis['recommendations'].add('Keep router firmware and client devices updated.');
    } else if (caps.contains('WPA2')) {
      analysis['encryption'] = 'WPA2';
      if (caps.contains('TKIP')) {
        analysis['vulnerable'] = true;
        analysis['risks'].add('Legacy TKIP detected.');
        analysis['recommendations'].add('Prefer WPA2-AES/CCMP or WPA3.');
      }
      if (caps.contains('WPS')) {
        analysis['vulnerable'] = true;
        analysis['risks'].add('WPS is enabled.');
        analysis['recommendations'].add('Disable WPS unless it is required.');
      }
    } else if (caps.contains('WPA')) {
      analysis['encryption'] = 'Legacy WPA';
      analysis['vulnerable'] = true;
      analysis['risks'].add('Legacy WPA detected.');
      analysis['recommendations'].add('Upgrade the access point to WPA2-AES or WPA3.');
    } else if (caps.contains('WEP')) {
      analysis['encryption'] = 'WEP';
      analysis['vulnerable'] = true;
      analysis['risks'].add('WEP is obsolete and insecure.');
      analysis['recommendations'].add('Replace WEP with WPA2-AES or WPA3.');
    } else if (caps.contains('ESS')) {
      analysis['encryption'] = 'Open';
      analysis['vulnerable'] = true;
      analysis['risks'].add('Open network; traffic is not protected by Wi-Fi encryption.');
      analysis['recommendations'].add('Use WPA2-AES or WPA3 on networks you control.');
    }

    return analysis;
  }

  /// Handshake capture is deliberately not implemented as an attack feature.
  /// Use approved enterprise auditing tooling outside this application.
  static Future<Map<String, dynamic>> captureHandshake(String bssid, {int timeout = 60}) async {
    return {
      'success': false,
      'bssid': bssid,
      'timeout': timeout,
      'error': 'Unsupported: packet capture is not provided by Zion OS.',
    };
  }

  /// Password cracking is deliberately disabled. Zion OS only reports
  /// defensive findings and never fabricates a recovered password.
  static Future<Map<String, dynamic>> crackWpa(String handshakeFile, List<String> wordlist) async {
    return {
      'success': false,
      'handshake_file': handshakeFile,
      'keys_tried': 0,
      'error': 'Disabled: credential cracking is not part of the production security model.',
    };
  }

  /// WPS exploitation is deliberately disabled.
  static Future<Map<String, dynamic>> wpsAttack(String bssid) async {
    return {
      'success': false,
      'bssid': bssid,
      'error': 'Disabled: WPS exploitation is not part of the production security model.',
    };
  }
}
