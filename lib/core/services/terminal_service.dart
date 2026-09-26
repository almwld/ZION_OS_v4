import 'dart:async';
import 'package:flutter/services.dart';

class TerminalService {
  TerminalService();
  final _channel = const MethodChannel('zion.os/pty');
  final _events = const EventChannel('zion.os/pty/events');
  StreamSubscription<dynamic>? _subscription;
  final _output = StreamController<String>.broadcast();
  bool _running = false;

  Stream<String> get output => _output.stream;
  bool get isRunning => _running;

  Future<bool> startInteractive({int rows = 30, int cols = 100}) async {
    if (_running) return true;
    _subscription = _events.receiveBroadcastStream().listen(
      (value) { if (value != null) _output.add(value.toString()); },
      onError: (error) => _output.add('[ZION] terminal error: ' + error.toString() + '\n'),
    );
    try {
      final result = await _channel.invokeMethod<bool>('start', {'rows': rows, 'cols': cols});
      _running = result ?? false;
      if (!_running) { await _subscription?.cancel(); _subscription = null; }
      return _running;
    } on PlatformException catch (e) {
      _output.add('[ZION] ' + e.code + ': ' + (e.message ?? 'terminal start failed') + '\n');
      await _subscription?.cancel();
      _subscription = null;
      return false;
    }
  }

  Future<void> write(String input) async {
    if (!_running) return;
    try { await _channel.invokeMethod<void>('write', {'input': input}); }
    on PlatformException catch (e) { _output.add('[ZION] ' + (e.message ?? e.code) + '\n'); }
  }

  Future<bool> resize({required int rows, required int cols}) async {
    if (!_running) return false;
    try { return await _channel.invokeMethod<bool>('resize', {'rows': rows, 'cols': cols}) ?? false; }
    catch (_) { return false; }
  }

  Future<void> stop() async {
    try { await _channel.invokeMethod<void>('stop'); } catch (_) {}
    _running = false;
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async { await stop(); await _output.close(); }
}
