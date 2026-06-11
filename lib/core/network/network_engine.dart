import 'dart:io';
import 'dart:async';

class NetworkEngine {
  static Future<List<String>> pingSweep(String subnet) async {
    final activeHosts = <String>[];
    final futures = <Future>[];
    
    for (var i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      futures.add(
        Process.run('ping', ['-c', '1', '-W', '1', ip])
          .then((result) {
            if (result.exitCode == 0) activeHosts.add(ip);
          }).catchError((_) {})
      );
    }
    await Future.wait(futures);
    return activeHosts;
  }
  
  static Future<List<int>> scanPorts(String host, List<int> ports) async {
    final openPorts = <int>[];
    for (final port in ports) {
      try {
        final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 1));
        socket.destroy();
        openPorts.add(port);
      } catch (_) {}
    }
    return openPorts;
  }
  
  static Future<String?> getBanner(String host, int port) async {
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 2));
      final completer = Completer<String?>();
      socket.listen((data) {
        completer.complete(String.fromCharCodes(data).trim());
        socket.destroy();
      });
      return await completer.future.timeout(const Duration(seconds: 2));
    } catch (_) {
      return null;
    }
  }
}
