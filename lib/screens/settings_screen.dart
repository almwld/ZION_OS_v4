import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _notifications = true;
  bool _soundEffects = true;
  bool _vibration = true;
  String _selectedLanguage = 'ar';
  int _fontSize = 14;
  double _iconSize = 58;
  String _currentPin = '1234';
  Color _selectedColor = const Color(0xFF00BCD4);

  final List<Color> _themeColors = [
    const Color(0xFF00BCD4), // Turquoise
    Colors.cyan,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? true;
      _notifications = prefs.getBool('notifications') ?? true;
      _soundEffects = prefs.getBool('sound_effects') ?? true;
      _vibration = prefs.getBool('vibration') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'ar';
      _fontSize = prefs.getInt('font_size') ?? 14;
      _iconSize = prefs.getDouble('icon_size') ?? 58;
      _currentPin = prefs.getString('user_pin') ?? '1234';
      final colorHex = prefs.getString('theme_color');
      if (colorHex != null) {
        _selectedColor = Color(int.parse(colorHex));
      }
    });
    _applyTheme();
    _applyLanguage();
    _applyFontSize();
  }

  void _applyTheme() {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.setDarkMode(_darkMode);
    provider.setPrimaryColor(_selectedColor);
  }

  void _applyLanguage() async {
    await context.setLocale(Locale(_selectedLanguage));
  }

  void _applyFontSize() {
    // تطبيق حجم الخط سيتم في الـ MaterialApp
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is double) await prefs.setDouble(key, value);
  }

  void _changeLanguage(String code) async {
    setState(() => _selectedLanguage = code);
    await _saveSetting('language', code);
    await context.setLocale(Locale(code));
    setState(() {});
  }

  void _changeThemeColor(Color color) {
    setState(() => _selectedColor = color);
    _saveSetting('theme_color', color.value.toString());
    Provider.of<ThemeProvider>(context, listen: false).setPrimaryColor(color);
  }

  void _changeFontSize(int size) {
    setState(() => _fontSize = size);
    _saveSetting('font_size', size);
  }

  void _changeIconSize(double size) {
    setState(() => _iconSize = size);
    _saveSetting('icon_size', size);
    Provider.of<ThemeProvider>(context, listen: false).setIconSize(size);
  }

  void _showChangePinDialog() {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('change_pin'.tr(), style: const TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'current_pin'.tr(),
                labelStyle: const TextStyle(color: Color(0xFF00BCD4)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPinCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'new_pin'.tr(),
                labelStyle: const TextStyle(color: Color(0xFF00BCD4)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPinCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'confirm_pin'.tr(),
                labelStyle: const TextStyle(color: Color(0xFF00BCD4)),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(), style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              if (oldPinCtrl.text == _currentPin) {
                if (newPinCtrl.text == confirmPinCtrl.text && newPinCtrl.text.length == 4) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_pin', newPinCtrl.text);
                  _currentPin = newPinCtrl.text;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN changed successfully'), backgroundColor: Color(0xFF00BCD4)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN mismatch'), backgroundColor: Colors.red),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wrong PIN'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('save'.tr(), style: const TextStyle(color: Color(0xFF00BCD4))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text('settings'.tr(), style: TextStyle(color: theme.primaryColor)),
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('appearance'.tr(), Icons.palette, theme),
          _buildThemeColorRow(theme),
          _buildLanguageRow(theme),
          _buildSliderRow('Font Size', _fontSize.toDouble(), 10, 20, (v) => _changeFontSize(v.toInt()), theme),
          _buildSliderRow('Icon Size', _iconSize, 48, 78, _changeIconSize, theme),
          _buildSwitchTile('dark_mode'.tr(), _darkMode, (v) {
            setState(() { _darkMode = v; _saveSetting('dark_mode', v); _applyTheme(); });
          }, theme),
          _buildSwitchTile('notifications'.tr(), _notifications, (v) {
            setState(() { _notifications = v; _saveSetting('notifications', v); });
          }, theme),
          _buildSwitchTile('sound_effects'.tr(), _soundEffects, (v) {
            setState(() { _soundEffects = v; _saveSetting('sound_effects', v); });
          }, theme),
          _buildSwitchTile('vibration'.tr(), _vibration, (v) {
            setState(() { _vibration = v; _saveSetting('vibration', v); });
          }, theme),
          _buildSection('security'.tr(), Icons.security, theme),
          _buildInfoTile('change_pin'.tr(), 'update_security_pin'.tr(), Icons.lock, _showChangePinDialog, theme),
          _buildInfoTile('biometric'.tr(), 'enable_fingerprint'.tr(), Icons.fingerprint, () {}, theme),
          _buildInfoTile('encryption'.tr(), 'aes256_active'.tr(), Icons.security, () {}, theme),
          _buildSection('about'.tr(), Icons.info, theme),
          _buildInfoTile('version'.tr(), 'Zion OS 4.0.0', Icons.info, () {}, theme),
          _buildInfoTile('developer'.tr(), 'Zion Security Team', Icons.code, () {}, theme),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 20),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildThemeColorRow(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('theme_color'.tr(), style: TextStyle(color: theme.primaryColor)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _themeColors.map((color) => GestureDetector(
              onTap: () => _changeThemeColor(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: _selectedColor == color ? Border.all(color: Colors.white, width: 3) : null,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('language'.tr(), style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
          DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: Colors.black,
            underline: const SizedBox(),
            style: const TextStyle(color: Color(0xFF00BCD4)),
            items: _languages.map((lang) => DropdownMenuItem(
              value: lang['code'],
              child: Row(
                children: [
                  Text(lang['flag']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(lang['name']!),
                ],
              ),
            )).toList(),
            onChanged: (v) => _changeLanguage(v!),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String title, double value, double min, double max, Function(double) onChanged, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
              Text('${value.toStringAsFixed(0)}', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: theme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
          Switch(value: value, onChanged: onChanged, activeColor: theme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon, VoidCallback onTap, ThemeProvider theme) {
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(title, style: TextStyle(color: theme.isDarkMode ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(color: theme.isDarkMode ? Colors.white54 : Colors.black54)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  Color _primaryColor = const Color(0xFF00BCD4);
  double _iconSize = 58;

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  double get iconSize => _iconSize;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setIconSize(double size) {
    _iconSize = size;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
