import 'dart:async';
import 'dart:io';

/// Network primitives that work from Dart/Flutter without depending on
/// Android/Linux shell commands such as ping, arp or netstat.
///
/// These operations are intended for networks the user is authorized to test.
class NetworkEngine {
  static const List<int> _discoveryPorts = <int>[
    53, 80, 443, 445, 139, 22, 23, 3389, 8080, 8443,
  ];

  static Future<List<String>> pingSweep(
    String subnet, {
    int concurrency = 24,
    Duration timeout = const Duration(milliseconds: 700),
  }) async {
    final normalized = subnet.trim().replaceFirst(RegExp(r'\.$'), '');
    if (!RegExp(r'^(?:\d{1,3}\.){2}\d{1,3}\$').hasMatch(normalized)) {
      throw const FormatException('Expected an IPv4 /24 prefix such as 192.168.1');
    }
    final octets = normalized.split('.').map(int.parse).toList();
    if (octets.any((value) => value > 255)) {
      throw const FormatException('Invalid IPv4 prefix');
    }

    final active = <String>{};
    final ips = List<String>.generate(254, (i) => '$normalized.${i + 1}');
    final safeConcurrency = concurrency.clamp(1, 64).toInt();

    for (var offset = 0; offset < ips.length; offset += safeConcurrency) {
      final batch = ips.skip(offset).take(safeConcurrency).toList();
      final results = await Future.wait(batch.map((ip) => _probeHost(ip, timeout)));
      for (var i = 0; i < results.length; i++) {
        if (results[i]) active.add(batch[i]);
      }
    }

    final sorted = active.toList()..sort(_compareIpv4);
    return sorted;
  }

  static Future<bool> _probeHost(String host, Duration timeout) async {
    for (final port in _discoveryPorts) {
      Socket? socket;
      try {
        socket = await Socket.connect(host, port, timeout: timeout);
        return true;
      } catch (_) {
        // Try the next common service port.
      } finally {
        socket?.destroy();
      }
    }
    return false;
  }

  static int _compareIpv4(String a, String b) {
    final aa = a.split('.').map(int.parse).toList();
    final bb = b.split('.').map(int.parse).toList();
    for (var i = 0; i < 4; i++) {
      final c = aa[i].compareTo(bb[i]);
      if (c != 0) return c;
    }
    return 0;
  }

  static Future<List<int>> scanPorts(
    String host,
    List<int> ports, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final openPorts = <int>[];
    final uniquePorts = ports.where((p) => p >= 1 && p <= 65535).toSet().toList()..sort();

    for (final port in uniquePorts) {
      Socket? socket;
      try {
        socket = await Socket.connect(host, port, timeout: timeout);
        openPorts.add(port);
      } catch (_) {
        // Closed, filtered or unreachable.
      } finally {
        socket?.destroy();
      }
    }
    return openPorts;
  }

  /// Reads a small amount of service data from explicitly selected TCP ports.
  /// No exploit or authentication bypass is attempted.
  static Future<Map<int, String>> scanWithBanner(
    String host,
    List<int> ports, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final results = <int, String>{};
    final uniquePorts = ports.where((p) => p >= 1 && p <= 65535).toSet().toList()..sort();

    for (final port in uniquePorts) {
      Socket? socket;
      StreamSubscription<List<int>>? subscription;
      final completer = Completer<String>();
      try {
        socket = await Socket.connect(host, port, timeout: timeout);
        subscription = socket.listen(
          (data) {
            if (!completer.isCompleted) {
              final text = String.fromCharCodes(data).trim();
              final limited = text.length > 512 ? text.substring(0, 512) : text;
              completer.complete(limited.isEmpty ? 'No banner' : limited);
            }
          },
          onError: (Object _) {
            if (!completer.isCompleted) completer.complete('No banner');
          },
          onDone: () {
            if (!completer.isCompleted) completer.complete('No banner');
          },
          cancelOnError: true,
        );
        final banner = await completer.future.timeout(timeout, onTimeout: () => 'No banner');
        if (banner != 'No banner') results[port] = banner;
      } catch (_) {
        // Ignore closed/filtered services.
      } finally {
        await subscription?.cancel();
        socket?.destroy();
      }
    }
    return results;
  }
}
