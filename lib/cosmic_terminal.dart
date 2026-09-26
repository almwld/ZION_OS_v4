import 'dart:async';
import 'package:flutter/material.dart';
import 'core/services/terminal_service.dart';

class CosmicTerminal extends StatefulWidget {
  const CosmicTerminal({super.key});
  @override
  State<CosmicTerminal> createState() => _CosmicTerminalState();
}

class _CosmicTerminalState extends State<CosmicTerminal> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _service = TerminalService();
  final _lines = <String>[];
  StreamSubscription<String>? _outputSubscription;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _outputSubscription = _service.output.listen((chunk) {
      if (!mounted) return;
      setState(() => _lines.addAll(chunk.split('\n')));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
    _start();
  }

  Future<void> _start() async {
    final ok = await _service.startInteractive();
    if (!mounted) return;
    setState(() => _running = ok);
    if (!ok) setState(() => _lines.add('[ZION] Terminal backend is unavailable.'));
  }

  Future<void> _submit(String value) async {
    _inputController.clear();
    if (value.trim().isEmpty || !_running) return;
    await _service.write(value + '\n');
  }

  @override
  void dispose() {
    _outputSubscription?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF07100A),
                border: Border(bottom: BorderSide(color: const Color(0xFF00FF41).withOpacity(.35))),
              ),
              child: Row(children: [
                const Icon(Icons.terminal, color: Color(0xFF00FF41)),
                const SizedBox(width: 10),
                const Text('ZION TERMINAL', style: TextStyle(color: Color(0xFF00FF41), fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(_running ? Icons.circle : Icons.circle_outlined, size: 10,
                    color: _running ? const Color(0xFF00FF41) : Colors.redAccent),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).maybePop()),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _lines.length,
                itemBuilder: (_, i) => SelectableText(_lines[i],
                  style: const TextStyle(color: Color(0xFFE6FFE9), fontFamily: 'monospace', fontSize: 13, height: 1.35)),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF101510),
                border: Border(top: BorderSide(color: Color(0xFF00FF41))),
              ),
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Row(children: [
                const Text('\$ ', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace')),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    autofocus: true,
                    enabled: _running,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    cursorColor: const Color(0xFF00FF41),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'command',
                      hintStyle: TextStyle(color: Colors.white38, fontFamily: 'monospace'),
                    ),
                    onSubmitted: _submit,
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
