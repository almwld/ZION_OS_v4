import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:riverpod/riverpod.dart';
import '../oracle_si.dart';

final unifiedCoreProvider = Provider<UnifiedCoreService>((ref) => UnifiedCoreService());

class UnifiedCoreService {
  final OracleSi _si = OracleSi();
  bool _siAwake = false;

  Future<String> execute(String command, {String? target, Map<String, String>? options}) async {
    try {
      if (command == 'awaken' || command == 'start_ai') {
        if (!_siAwake) { _siAwake = true; _si.awaken(); return '🔮 Si العراف استيقظ. أنا أرى التهديدات قبل حدوثها.'; }
        return '🔮 Si مستيقظ بالفعل.';
      }

      if (command == 'oracle_report' || command == 'تقرير_العراف') {
        return const JsonEncoder.withIndent('  ').convert(_si.getOracleReport());
      }

      if (command == 'predictions' || command == 'تنبؤات') {
        return const JsonEncoder.withIndent('  ').convert(_si._predictedThreats);
      }

      if (command == 'risk_level' || command == 'مستوى_الخطر') {
        return 'مستوى الخطر الحالي: ${_si._calculateOverallRisk()}';
      }

      if (command == 'guard_report' || command == 'تقرير_الحماية') {
        return const JsonEncoder.withIndent('  ').convert(_si.getGuardianReport());
      }

      if (command == 'block_ip' || command == 'حظر') {
        if (target == null) return '⚠️ استخدم: block_ip <IP>';
        _si._blockIP(target, 'manual_block');
        return '🚫 تم حظر $target';
      }

      if (command == 'threat_log' || command == 'سجل_التهديدات') {
        return const JsonEncoder.withIndent('  ').convert(_si._threatLog.reversed.take(20).toList());
      }

      if (command == 'loyalty_report' || command == 'تقرير_الولاء') return const JsonEncoder.withIndent('  ').convert(_si.getLoyaltyReport());
      if (command == 'si_status' || command == 'ai_status') return const JsonEncoder.withIndent('  ').convert(_si.getStatus());
      if (command == 'si_sleep' || command == 'stop_ai') { _si.sleep(); _siAwake = false; return '😴 Si نام.'; }

      if (_siAwake) return await _si.executeUserCommand(command, target: target);

      switch (command) {
        case 'ping': return await _ping(target ?? '127.0.0.1');
        case 'port_scan': return await _portScan(target ?? '127.0.0.1');
        case 'dns_lookup': return await _dnsLookup(target ?? 'google.com');
        case 'http_headers': return await _httpHeaders(target ?? 'http://google.com');
        case 'system_info': return _systemInfo();
        case 'help': return _helpText();
        default: return 'Unknown command: $command';
      }
    } catch (e) { return 'Error: $e'; }
  }

  Future<String> _ping(String t) async { try { return (await Process.run('ping', ['-c', '4', t], runInShell: true)).stdout.toString(); } catch (e) { return 'Ping failed: $e'; } }
  Future<String> _portScan(String t) async { final p = [21,22,23,25,53,80,443,8080,8443]; final o = <String>[]; for (final x in p) { try { final s = await Socket.connect(t, x, timeout: const Duration(milliseconds: 500)); o.add('$x (open)'); s.destroy(); } catch (_) {} } return 'Port scan on $t:\n${o.isNotEmpty ? o.join('\n') : "No open ports found"}'; }
  Future<String> _dnsLookup(String d) async { try { final a = await InternetAddress.lookup(d); return 'DNS: $d\n${a.map((x) => '${x.address} (${x.type.name})').join('\n')}'; } catch (e) { return 'DNS failed: $e'; } }
  Future<String> _httpHeaders(String u) async { try { final c = HttpClient(); final r = await c.getUrl(Uri.parse(u)); final res = await r.close(); final h = res.headers; final o = StringBuffer(); h.forEach((k,v) => o.writeln('$k: ${v.join(', ')}')); return 'HTTP Headers for $u:\n$o'; } catch (e) { return 'HTTP failed: $e'; } }
  String _systemInfo() => 'OS: ${Platform.operatingSystem}\nCPU: ${Platform.numberOfProcessors} cores\nDart: ${Platform.version}';

  String _helpText() => '''
=== PROJECT ZION - ORACLE Si ===
awaken / start_ai      - إيقاظ العراف
oracle_report          - تقرير البصيرة
predictions / تنبؤات   - التهديدات المتوقعة
risk_level / مستوى_الخطر - مستوى الخطر
guard_report           - تقرير الحماية
block_ip <IP>          - حظر IP
threat_log             - سجل التهديدات
si_status              - حالة Si
help                   - مساعدة
================================
''';
}
