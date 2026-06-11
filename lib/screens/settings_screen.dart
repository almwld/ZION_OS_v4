import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PreferencesService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr()), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('settings.appearance'.tr(), [
            _buildSwitchTile('settings.dark_mode'.tr(), prefs.isDarkMode, (v) => prefs.setDarkMode(v), prefs),
            _buildLanguageTile(prefs),
          ], prefs),
          _buildSection('settings.security'.tr(), [
            _buildInfoTile('settings.change_pin'.tr(), () {}, prefs),
            _buildSwitchTile('settings.biometric'.tr(), prefs.useBiometric, (v) => prefs.setUseBiometric(v), prefs),
          ], prefs),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, PreferencesService prefs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyan)),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, PreferencesService prefs) {
    return Card(
      child: SwitchListTile(
        title: Text(title, style: TextStyle(fontSize: 14 * prefs.fontScale)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.cyan,
      ),
    );
  }

  Widget _buildInfoTile(String title, VoidCallback onTap, PreferencesService prefs) {
    return Card(
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 14 * prefs.fontScale)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageTile(PreferencesService prefs) {
    return Card(
      child: ListTile(
        title: Text('settings.language'.tr()),
        trailing: DropdownButton<String>(
          value: prefs.languageCode,
          items: const [
            DropdownMenuItem(value: 'ar', child: Text('العربية')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (v) {
            if (v != null) {
              prefs.setLanguageCode(v);
              context.setLocale(Locale(v));
            }
          },
        ),
      ),
    );
  }
}
