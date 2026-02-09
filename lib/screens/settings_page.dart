import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storeNameController = TextEditingController();
  String? _logoPath;
  String _language = 'en';
  final _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _storeNameController.text = _settings.storeName;
    _logoPath =
        _settings.storeLogoPath.isEmpty ? null : _settings.storeLogoPath;
    _language = _settings.language;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await _settings.setStoreLogoPath(path);
      setState(() {
        _logoPath = path;
      });
    }
  }

  Future<void> _save() async {
    await _settings.setStoreName(_storeNameController.text.trim());
    await _settings.setLanguage(_language);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Store profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _storeNameController,
            decoration: const InputDecoration(
              labelText: 'Store name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.image),
                  label: const Text('Choose logo'),
                ),
              ),
              const SizedBox(width: 12),
              if (_logoPath != null)
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.file(
                    File(_logoPath!),
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Language',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _language,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ar', child: Text('Arabic')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _language = val);
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
