import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class CosmicTerminal extends StatefulWidget {
  const CosmicTerminal({super.key});

  @override
  State<CosmicTerminal> createState() => _CosmicTerminalState();
}

class _CosmicTerminalState extends State<CosmicTerminal> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<TerminalLine> _lines = [];
  bool _isExecuting = false;
  Process? _currentProcess;

  // قائمة الأوامر المدعومة
  final Map<String, Function> _commands = {};

  @override
  void initState() {
    super.initState();
    _registerCommands();
    _addWelcomeMessage();
  }

  void _registerCommands() {
    _commands['help'] = _showHelp;
    _commands['clear'] = _clearScreen;
    _commands['exit'] = _exitTerminal;
    _commands['scan'] = _executeScan;
    _commands['attack'] = _executeAttack;
    _commands['status'] = _showStatus;
  }

  void _addWelcomeMessage() {
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('🔥 Zion OS v2.0 - Cosmic Terminal');
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('');
    _addLine('📡 Available Commands:');
    _addLine('  help     - Show this help');
    _addLine('  clear    - Clear screen');
    _addLine('  scan     - Scan network');
    _addLine('  attack   - Execute attack');
    _addLine('  status   - Show system status');
    _addLine('  exit     - Close terminal');
    _addLine('');
    _addLine('═══════════════════════════════════════════════════════════════');
  }

  void _addLine(String text, {bool isError = false, bool isCommand = false}) {
    setState(() {
      _lines.add(TerminalLine(
        text: text,
        isError: isError,
        isCommand: isCommand,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _executeCommand(String command) async {
    if (command.trim().isEmpty) return;

    _addLine('zion@os:~$ $command', isCommand: true);
    _inputController.clear();
    setState(() => _isExecuting = true);

    final cmd = command.trim().split(' ').first.toLowerCase();
    final args = command.trim().split(' ').skip(1).toList();

    if (_commands.containsKey(cmd)) {
      try {
        await _commands[cmd]!(args);
      } catch (e) {
        _addLine('Error: $e', isError: true);
      }
    } else {
      _addLine('Command not found: $cmd. Type "help" for available commands.', isError: true);
    }

    setState(() => _isExecuting = false);
    _addLine('');
  }

  void _showHelp(List<String> args) {
    _addLine('');
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('📚 COMMAND REFERENCE');
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('');
    _addLine('  help                    - Show this help');
    _addLine('  clear                   - Clear terminal screen');
    _addLine('  exit                    - Close terminal');
    _addLine('  scan <target>           - Scan target (e.g., scan 192.168.1.1)');
    _addLine('  attack <target> <type>  - Execute attack (e.g., attack 192.168.1.1 ssh)');
    _addLine('  status                  - Show system status');
    _addLine('');
    _addLine('═══════════════════════════════════════════════════════════════');
  }

  void _clearScreen(List<String> args) {
    setState(() => _lines.clear());
    _addWelcomeMessage();
  }

  void _exitTerminal(List<String> args) {
    _currentProcess?.kill();
    Navigator.pop(context);
  }

  Future<void> _executeScan(List<String> args) async {
    if (args.isEmpty) {
      _addLine('Usage: scan <target>', isError: true);
      return;
    }
    final target = args[0];
    _addLine('🔍 Scanning $target...');
    await Future.delayed(const Duration(seconds: 2));
    _addLine('✅ Scan completed. Found: 3 open ports (22, 80, 443)');
  }

  Future<void> _executeAttack(List<String> args) async {
    if (args.length < 2) {
      _addLine('Usage: attack <target> <type>', isError: true);
      _addLine('Types: ssh, ftp, web, eternalblue', isError: true);
      return;
    }
    final target = args[0];
    final type = args[1];
    _addLine('⚔️ Executing $type attack on $target...');
    await Future.delayed(const Duration(seconds: 3));
    _addLine('✅ Attack completed. Vulnerability found!');
  }

  Future<void> _showStatus(List<String> args) async {
    _addLine('');
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('📊 SYSTEM STATUS');
    _addLine('═══════════════════════════════════════════════════════════════');
    _addLine('  Version:     Zion OS v2.0');
    _addLine('  Tools:       1000+');
    _addLine('  SI Agent:    Active');
    _addLine('  Neural Net:  Online');
    _addLine('  Status:      Ready');
    _addLine('═══════════════════════════════════════════════════════════════');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildTerminalOutput()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade900, Colors.black]),
        border: Border(bottom: BorderSide(color: Colors.green.shade700)),
      ),
      child: Row(
        children: [
          const Icon(Icons.terminal, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Text('COSMIC TERMINAL', style: TextStyle(color: Colors.green.shade400, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (_isExecuting) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildTerminalOutput() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _lines.length,
      itemBuilder: (context, index) {
        final line = _lines[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SelectableText(
            line.text,
            style: TextStyle(
              color: line.isError ? Colors.red.shade400 : (line.isCommand ? Colors.green.shade400 : Colors.white),
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(top: BorderSide(color: Colors.green.shade700)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Text('zion@os:~$ ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter command...', hintStyle: TextStyle(color: Colors.grey)),
              onSubmitted: _executeCommand,
              enabled: !_isExecuting,
            ),
          ),
        ],
      ),
    );
  }
}

class TerminalLine {
  final String text;
  final bool isError;
  final bool isCommand;
  final DateTime timestamp;
  TerminalLine({required this.text, this.isError = false, this.isCommand = false, required this.timestamp});
}
