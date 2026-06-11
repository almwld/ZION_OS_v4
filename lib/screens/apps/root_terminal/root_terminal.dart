import 'package:flutter/material.dart';
import '../../../core/services/root_service.dart';
import 'dart:async';

class RootTerminalApp extends StatefulWidget {
  const RootTerminalApp({super.key});

  @override
  State<RootTerminalApp> createState() => _RootTerminalAppState();
}

class _RootTerminalAppState extends State<RootTerminalApp> {
  final TextEditingController _commandController = TextEditingController();
  final List<String> _output = [];
  final ScrollController _scrollController = ScrollController();
  final RootService _rootService = RootService();
  bool _isLoading = false;
  bool _hasRoot = false;

  @override
  void initState() {
    super.initState();
    _checkRoot();
  }

  Future<void> _checkRoot() async {
    final status = await _rootService.getRootStatus();
    setState(() {
      _hasRoot = status['granted'] ?? false;
    });
    if (!_hasRoot) {
      _output.add('[!] صلاحيات الجذر غير مفعلة. استخدم زر "منح الصلاحيات" أولاً.');
    } else {
      _output.add('[#] محطة الجذر (Root Terminal) جاهزة.');
      _output.add('[#] اكتب أوامرك واضغط Enter.');
    }
  }

  Future<void> _executeCommand() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;

    setState(() {
      _output.add("\$ $command");
      _commandController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final result = await _rootService.runAsRoot(command);
      setState(() {
        if (result.stdout.toString().isNotEmpty) {
          _output.add(result.stdout.toString().trim());
        }
        if (result.stderr.toString().isNotEmpty) {
          _output.add("[ERROR] ${result.stderr.toString().trim()}");
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _output.add("[ERROR] $e");
        _isLoading = false;
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

  void _clearOutput() {
    setState(() {
      _output.clear();
    });
  }

  Future<void> _requestRootAccess() async {
    final granted = await _rootService.requestRootAccess();
    setState(() {
      _hasRoot = granted;
    });
    if (granted) {
      _output.add('[#] تم منح صلاحيات الجذر بنجاح.');
    } else {
      _output.add('[!] فشل منح صلاحيات الجذر.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Root Terminal', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Color(0xFF00BCD4)),
            onPressed: _clearOutput,
          ),
          if (!_hasRoot)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Color(0xFF00BCD4)),
              onPressed: _requestRootAccess,
              tooltip: 'منح صلاحيات الجذر',
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasRoot && !_isLoading)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('صلاحيات الجذر غير مفعلة', style: TextStyle(color: Colors.white70))),
                  ElevatedButton(
                    onPressed: _requestRootAccess,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), foregroundColor: Colors.black),
                    child: const Text('منح الصلاحيات'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _output.length,
                itemBuilder: (context, index) {
                  final line = _output[index];
                  final isCommand = line.startsWith('\$');
                  final isError = line.startsWith('[ERROR]');
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                      line,
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
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(_hasRoot ? '#' : '\$', style: const TextStyle(color: Color(0xFF00BCD4), fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: _hasRoot ? 'أمر بصلاحيات الجذر...' : 'الرجاء منح صلاحيات الجذر أولاً',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _executeCommand(),
                    enabled: _hasRoot,
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send, color: Color(0xFF00BCD4)),
                  onPressed: _hasRoot && !_isLoading ? _executeCommand : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
