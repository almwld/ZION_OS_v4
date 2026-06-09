import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/wm/window_manager.dart';

class ZionTaskbar extends StatelessWidget {
  const ZionTaskbar({super.key});

  @override
  Widget build(BuildContext context) {
    final wm = context.watch<WindowManager>();
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E0A),
        border: Border(top: BorderSide(color: Color(0xFF1A3A1A))),
      ),
      child: Row(
        children: [
          // قائمة ابدأ
          _TaskbarButton(icon: Icons.menu, label: 'ابدأ', onTap: () => _showStartMenu(context)),
          const SizedBox(width: 8),
          // النوافذ المفتوحة
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: wm.windows.map((window) => _TaskbarButton(
                icon: Icons.terminal,
                label: window.title,
                isActive: wm.activeWindowId == window.id,
                onTap: () => wm.setActive(window.id),
              )).toList(),
            ),
          ),
          // النوافذ المصغرة
          ...wm.minimizedWindows.map((window) => _TaskbarButton(
            icon: Icons.terminal,
            label: window.title,
            onTap: () => wm.minimize(window.id),
          )),
          // الساعة
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('21:37', style: TextStyle(color: Color(0xFF00FF41), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showStartMenu(BuildContext context) {
    final wm = context.read<WindowManager>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0E0A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF00FF41))),
        title: const Text('Zion Linux', style: TextStyle(color: Color(0xFF00FF41))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StartMenuItem(icon: Icons.terminal, label: 'الطرفية', onTap: () { Navigator.pop(ctx); wm.open('Terminal', const CosmicTerminalDesktop(), width: 500, height: 350); }),
            _StartMenuItem(icon: Icons.language, label: 'متصفح', onTap: () { Navigator.pop(ctx); wm.open('Browser', const Text('Web Browser (Soon)', style: TextStyle(color: Colors.white)), width: 700, height: 500); }),
            _StartMenuItem(icon: Icons.edit, label: 'محرر نصوص', onTap: () { Navigator.pop(ctx); wm.open('Editor', const Text('Text Editor (Soon)', style: TextStyle(color: Colors.white)), width: 500, height: 400); }),
            _StartMenuItem(icon: Icons.shield, label: 'الترسانة', onTap: () { Navigator.pop(ctx); wm.open('Arsenal', const Text('Arsenal (Soon)', style: TextStyle(color: Colors.white)), width: 400, height: 500); }),
            const Divider(color: Color(0xFF1A3A1A)),
            _StartMenuItem(icon: Icons.power_settings_new, label: 'إيقاف التشغيل', onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }
}

class _StartMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _StartMenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon, color: const Color(0xFF00FF41), size: 20), title: Text(label, style: const TextStyle(color: Color(0xFF00FF41), fontSize: 14)), dense: true, onTap: onTap);
  }
}

class _TaskbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TaskbarButton({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00FF41).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? const Color(0xFF00FF41) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF00FF41), size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Color(0xFF00FF41), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class CosmicTerminalDesktop extends StatefulWidget {
  const CosmicTerminalDesktop({super.key});

  @override
  State<CosmicTerminalDesktop> createState() => _CosmicTerminalDesktopState();
}

class _CosmicTerminalDesktopState extends State<CosmicTerminalDesktop> {
  final TextEditingController _cmdCtrl = TextEditingController();
  final List<String> _output = ['Zion Terminal v5.0', 'اكتب "help" للمساعدة.'];
  final ScrollController _scrollCtrl = ScrollController();

  void _execute(String cmd) {
    setState(() {
      _output.add('> $cmd');
      switch (cmd.trim().toLowerCase()) {
        case 'help': _output.add('ls, pwd, whoami, date, clear, nmap, msfconsole, help'); break;
        case 'clear': _output.clear(); break;
        case 'ls': _output.add('bin boot dev etc home lib media mnt opt proc root run sbin srv sys tmp usr var'); break;
        case 'pwd': _output.add('/home/zion'); break;
        case 'whoami': _output.add('root'); break;
        case 'date': _output.add(DateTime.now().toString()); break;
        default: _output.add('command not found: $cmd');
      }
    });
    _cmdCtrl.clear();
    _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(8),
            itemCount: _output.length,
            itemBuilder: (context, i) => Text(_output[i], style: TextStyle(color: _output[i].startsWith('>') ? const Color(0xFF00FF41) : Colors.white70, fontFamily: 'monospace', fontSize: 12)),
          ),
        ),
        Container(
          decoration: const BoxDecoration(color: Color(0xFF0A0E0A), border: Border(top: BorderSide(color: Color(0xFF1A3A1A)))),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            const Text('zion:~# ', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 12)),
            Expanded(child: TextField(controller: _cmdCtrl, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12), decoration: const InputDecoration(border: InputBorder.none, isDense: true), cursorColor: const Color(0xFF00FF41), onSubmitted: _execute)),
          ]),
        ),
      ],
    );
  }
}
