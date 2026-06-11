import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class TerminalApp extends StatefulWidget {
  const TerminalApp({super.key});

  @override
  State<TerminalApp> createState() => _TerminalAppState();
}

class _TerminalAppState extends State<TerminalApp> {
  final TextEditingController _commandController = TextEditingController();
  final List<String> _output = [];
  final ScrollController _scrollController = ScrollController();
  String _currentDir = '/data/data/com.termux/files/home';

  @override
  void initState() {
    super.initStatusBar();
    _updateDir();
  }

  void _updateDir() {
    try {
      final result = Process.runSync('pwd', [], runInShell: true);
      if (result.exitCode == 0) {
        _currentDir = result.stdout.toString().trim();
      }
    } catch (_) {}
  }

  void _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;
    
    setState(() {
      _output.add("\$ $command");
      _commandController.clear();
    });
    
    if (command == 'clear' || command == 'cls') {
      setState(() => _output.clear());
      return;
    }
    
    if (command == 'pwd') {
      setState(() => _output.add(_currentDir));
      _scrollToBottom();
      return;
    }
    
    if (command.startsWith('cd ')) {
      final newDir = command.substring(3).trim();
      try {
        final dir = Directory(newDir.startsWith('/') ? newDir : '$_currentDir/$newDir');
        if (await dir.exists()) {
          _currentDir = dir.path;
          setState(() => _output.add('Changed directory to $_currentDir'));
        } else {
          setState(() => _output.add('Directory not found: $newDir'));
        }
      } catch (_) {
        setState(() => _output.add('Invalid directory: $newDir'));
      }
      _scrollToBottom();
      return;
    }
    
    try {
      final result = await Process.run('sh', ['-c', command], workingDirectory: _currentDir, runInShell: true);
      setState(() {
        if (result.stdout.toString().isNotEmpty) {
          _output.add(result.stdout.toString().trim());
        }
        if (result.stderr.toString().isNotEmpty) {
          _output.add("\x1b[31m${result.stderr.toString().trim()}\x1b[0m");
        }
      });
    } catch (e) {
      setState(() {
        _output.add("\x1b[31mError: $e\x1b[0m");
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Terminal', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/eye_of_horus.svg'),
            fit: BoxFit.contain,
            alignment: Alignment.center,
            opacity: 0.08,
          ),
        ),
        child: Column(
          children: [
            // شريط معلومات
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              color: Colors.black.withOpacity(0.7),
              child: Row(
                children: [
                  const Icon(Icons.terminal, color: Color(0xFF00BCD4), size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentDir,
                      style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 11, fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF00BCD4), shape: BoxShape.circle),
                  ),
                ],
              ),
            ),
            // Terminal Output
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _output.length,
                  itemBuilder: (context, index) {
                    final line = _output[index];
                    final isCommand = line.startsWith('\$');
                    final isError = line.contains('\x1b[31m');
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SelectableText(
                        line.replaceAll('\x1b[31m', '').replaceAll('\x1b[0m', ''),
                        style: TextStyle(
                          color: isError ? Colors.red : (isCommand ? const Color(0xFF00BCD4) : Colors.white70),
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Input Bar
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      color: const Color(0xFF00BCD4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commandController,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        hintText: 'Enter command...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _executeCommand(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF00BCD4), size: 20),
                    onPressed: _executeCommand,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
