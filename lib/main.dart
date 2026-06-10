import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// استيراد جميع الصفحات
import 'zion_desktop.dart';
import 'zion_home.dart';
import 'zion_lock_screen.dart';
import 'zion_app_launcher.dart';
import 'zion_browser.dart';
import 'zion_file_manager.dart';
import 'zion_text_editor.dart';
import 'zion_system_monitor.dart';
import 'zion_network_manager.dart';
import 'zion_security_suite.dart';
import 'zion_user_system.dart';
import 'zion_backup_system.dart';
import 'zion_log_system.dart';
import 'zion_ota_system.dart';
import 'zion_plugin_system.dart';
import 'zion_recovery_system.dart';
import 'zion_reporting_system.dart';
import 'zion_scripting_engine.dart';
import 'zion_theme_engine.dart';
import 'zion_power_management.dart';
import 'zion_quantum_encryption.dart';
import 'zion_ar_hacking.dart';
import 'zion_deep_learning_attack.dart';
import 'zion_attack_panel.dart';
import 'zion_ai_assistant.dart';
import 'zion_advanced_terminal.dart';
import 'cosmic_terminal.dart';
import 'features/dashboard/cosmic_dashboard.dart';
import 'features/terminal/terminal_screen.dart';
import 'features/network/cosmic_network_map.dart';
import 'features/sniffing/packet_sniffer_screen.dart';
import 'features/exploitation/exploit_screen.dart';
import 'features/recon/network_map_screen.dart';
import 'features/monitor/cosmic_monitor.dart';
import 'features/reports/reports_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/tool_runner/tool_runner_screen.dart';

// استيراد الـ Arsenal (1000 أداة)
import 'core/arsenal/zion_net.dart';
import 'core/arsenal/zion_crack.dart';
import 'core/arsenal/zion_exploit.dart';
import 'core/arsenal/zion_web.dart';
import 'core/arsenal/zion_wireless.dart';
import 'core/arsenal/zion_mitm.dart';
import 'core/arsenal/zion_forensics.dart';
import 'core/arsenal/zion_postexploit.dart';
import 'core/arsenal/zion_evasion.dart';
import 'core/arsenal/zion_advanced.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تثبيت اتجاه الشاشة
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  runApp(const ZionOS());
}

class ZionOS extends StatelessWidget {
  const ZionOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zion OS - Cyber Security Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.green,
        primarySwatch: Colors.green,
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.green,
      ),
      themeMode: ThemeMode.dark,
      home: const AppModeSelector(),
    );
  }
}

// شاشة اختيار الوضع (App / Desktop)
class AppModeSelector extends StatefulWidget {
  const AppModeSelector({super.key});

  @override
  State<AppModeSelector> createState() => _AppModeSelectorState();
}

class _AppModeSelectorState extends State<AppModeSelector> {
  bool _isDesktopMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isDesktopMode ? const ZionDesktop() : const ZionHome(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isDesktopMode = !_isDesktopMode;
          });
        },
        backgroundColor: Colors.green,
        child: Icon(_isDesktopMode ? Icons.phone_android : Icons.desktop_windows),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// الصفحات المتاحة في التطبيق
class AppPages {
  static const List<PageItem> pages = [
    PageItem(title: 'Home', icon: Icons.home, page: ZionHome()),
    PageItem(title: 'Desktop', icon: Icons.desktop_windows, page: ZionDesktop()),
    PageItem(title: 'Lock Screen', icon: Icons.lock, page: ZionLockScreen()),
    PageItem(title: 'App Launcher', icon: Icons.apps, page: ZionAppLauncher()),
    PageItem(title: 'Browser', icon: Icons.public, page: ZionBrowser()),
    PageItem(title: 'File Manager', icon: Icons.folder, page: ZionFileManager()),
    PageItem(title: 'Text Editor', icon: Icons.edit, page: ZionTextEditor()),
    PageItem(title: 'System Monitor', icon: Icons.speed, page: ZionSystemMonitor()),
    PageItem(title: 'Network Manager', icon: Icons.wifi, page: ZionNetworkManager()),
    PageItem(title: 'Security Suite', icon: Icons.security, page: ZionSecuritySuite()),
    PageItem(title: 'User System', icon: Icons.people, page: ZionUserSystem()),
    PageItem(title: 'Backup System', icon: Icons.backup, page: ZionBackupSystem()),
    PageItem(title: 'Log System', icon: Icons.list, page: ZionLogSystem()),
    PageItem(title: 'OTA System', icon: Icons.update, page: ZionOTASystem()),
    PageItem(title: 'Plugin System', icon: Icons.extension, page: ZionPluginSystem()),
    PageItem(title: 'Recovery System', icon: Icons.restore, page: ZionRecoverySystem()),
    PageItem(title: 'Reporting System', icon: Icons.bar_chart, page: ZionReportingSystem()),
    PageItem(title: 'Scripting Engine', icon: Icons.code, page: ZionScriptingEngine()),
    PageItem(title: 'Theme Engine', icon: Icons.palette, page: ZionThemeEngine()),
    PageItem(title: 'Power Management', icon: Icons.battery_full, page: ZionPowerManagement()),
    PageItem(title: 'Quantum Encryption', icon: Icons.enhanced_encryption, page: ZionQuantumEncryption()),
    PageItem(title: 'AR Hacking', icon: Icons.view_in_ar, page: ZionArHacking()),
    PageItem(title: 'Deep Learning Attack', icon: Icons.psychology, page: ZionDeepLearningAttack()),
    PageItem(title: 'Attack Panel', icon: Icons.flash_on, page: ZionAttackPanel()),
    PageItem(title: 'AI Assistant', icon: Icons.smart_toy, page: ZionAIAssistant()),
    PageItem(title: 'Advanced Terminal', icon: Icons.terminal, page: ZionAdvancedTerminal()),
    PageItem(title: 'Cosmic Terminal', icon: Icons.terminal, page: CosmicTerminal()),
    PageItem(title: 'Cosmic Dashboard', icon: Icons.dashboard, page: CosmicDashboard()),
    PageItem(title: 'Terminal Screen', icon: Icons.terminal, page: const TerminalScreen()),
    PageItem(title: 'Network Map', icon: Icons.map, page: const CosmicNetworkMap()),
    PageItem(title: 'Packet Sniffer', icon: Icons.wifi_tethering, page: const PacketSnifferScreen()),
    PageItem(title: 'Exploit Screen', icon: Icons.bug_report, page: const ExploitScreen()),
    PageItem(title: 'Network Map Screen', icon: Icons.map, page: const NetworkMapScreen()),
    PageItem(title: 'Cosmic Monitor', icon: Icons.monitor, page: const CosmicMonitor()),
    PageItem(title: 'Reports Screen', icon: Icons.report, page: const ReportsScreen()),
    PageItem(title: 'Settings Screen', icon: Icons.settings, page: const SettingsScreen()),
    PageItem(title: 'Tool Runner', icon: Icons.play_arrow, page: const ToolRunnerScreen()),
    
    // أدوات Arsenal (1000 أداة)
    PageItem(title: 'ZionNet - Network', icon: Icons.network_check, page: ZionNetWidget()),
    PageItem(title: 'ZionCrack - Password', icon: Icons.lock_open, page: ZionCrackWidget()),
    PageItem(title: 'ZionExploit - Exploits', icon: Icons.flash_on, page: ZionExploitWidget()),
    PageItem(title: 'ZionWeb - Web', icon: Icons.web, page: ZionWebWidget()),
    PageItem(title: 'ZionWireless - WiFi', icon: Icons.wifi, page: ZionWirelessWidget()),
    PageItem(title: 'ZionMITM - MITM', icon: Icons.swap_horiz, page: ZionMITMWidget()),
    PageItem(title: 'ZionForensics', icon: Icons.analytics, page: ZionForensicsWidget()),
    PageItem(title: 'ZionPostExploit', icon: Icons.arrow_forward, page: ZionPostExploitWidget()),
    PageItem(title: 'ZionEvasion', icon: Icons.visibility_off, page: ZionEvasionWidget()),
    PageItem(title: 'ZionAdvanced', icon: Icons.rocket, page: ZionAdvancedWidget()),
  ];
}

class PageItem {
  final String title;
  final IconData icon;
  final Widget page;
  
  const PageItem({required this.title, required this.icon, required this.page});
}

// ============================================================
// أدوات Arsenal (1000 أداة) - واجهات مبسطة
// ============================================================

class ZionNetWidget extends StatelessWidget {
  const ZionNetWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionNet - Network Arsenal (100 tools)')),
      body: const Center(child: Text('Network scanning tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionCrackWidget extends StatelessWidget {
  const ZionCrackWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionCrack - Password Arsenal (100 tools)')),
      body: const Center(child: Text('Password cracking tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionExploitWidget extends StatelessWidget {
  const ZionExploitWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionExploit - Exploit Arsenal (100 tools)')),
      body: const Center(child: Text('Exploitation tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionWebWidget extends StatelessWidget {
  const ZionWebWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionWeb - Web Arsenal (100 tools)')),
      body: const Center(child: Text('Web penetration testing tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionWirelessWidget extends StatelessWidget {
  const ZionWirelessWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionWireless - Wireless Arsenal (100 tools)')),
      body: const Center(child: Text('WiFi/Bluetooth hacking tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionMITMWidget extends StatelessWidget {
  const ZionMITMWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionMITM - MITM Arsenal (100 tools)')),
      body: const Center(child: Text('Man-in-the-middle tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionForensicsWidget extends StatelessWidget {
  const ZionForensicsWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionForensics - Forensics Arsenal (100 tools)')),
      body: const Center(child: Text('Digital forensics tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionPostExploitWidget extends StatelessWidget {
  const ZionPostExploitWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionPostExploit - Post-Exploit Arsenal (100 tools)')),
      body: const Center(child: Text('Post-exploitation tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionEvasionWidget extends StatelessWidget {
  const ZionEvasionWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionEvasion - Evasion Arsenal (100 tools)')),
      body: const Center(child: Text('Anti-forensics & evasion tools ready', style: TextStyle(color: Colors.green))),
    );
  }
}

class ZionAdvancedWidget extends StatelessWidget {
  const ZionAdvancedWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZionAdvanced - Advanced Arsenal (100 tools)')),
      body: const Center(child: Text('AI-powered & advanced attacks ready', style: TextStyle(color: Colors.green))),
    );
  }
}
