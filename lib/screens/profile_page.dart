import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';
import '../services/settings_service.dart';
import '../database/manager_dao.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storeNameController = TextEditingController();
  final _lowStockController = TextEditingController();

  String? _logoPath;

  final _settings = SettingsService.instance;

  @override
  void initState() {
    super.initState();

    _storeNameController.text = _settings.storeName;
    _lowStockController.text = _settings.lowStockThreshold.toString();
    _logoPath = _settings.storeLogoPath.isEmpty ? null : _settings.storeLogoPath;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await _settings.setStoreLogoPath(path);
      setState(() => _logoPath = path);
    }
  }

  Future<void> _saveStoreInfo() async {
    final t = AppLocalizations.of(context)!;

    await _settings.setStoreName(_storeNameController.text.trim());

    final threshold = int.tryParse(_lowStockController.text.trim());
    if (threshold == null || threshold <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidLowStockThreshold)),
      );
      return;
    }

    await _settings.setLowStockThreshold(threshold);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.profileSaved)),
    );
  }

  void _changePinDialog() async {
    final t = AppLocalizations.of(context)!;

    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final hasExistingPin = await ManagerDao.hasPin();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(t.changeManagerPin),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasExistingPin) ...[
                    TextField(
                      controller: oldPinController,
                      obscureText: obscureOld,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: t.currentPin,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureOld ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => obscureOld = !obscureOld),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: newPinController,
                    obscureText: obscureNew,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t.newPin,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmPinController,
                    obscureText: obscureConfirm,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: t.confirmNewPin,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Verify old PIN if exists
                    if (hasExistingPin) {
                      final ok = await ManagerDao.verifyPin(oldPinController.text);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.incorrectCurrentPin)),
                        );
                        return;
                      }
                    }

                    // Validate new PIN
                    if (newPinController.text.length != 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.pinMustBe4Digits)),
                      );
                      return;
                    }

                    if (newPinController.text != confirmPinController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.pinsDoNotMatch)),
                      );
                      return;
                    }

                    // Save new PIN
                    await ManagerDao.savePin(newPinController.text);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.pinUpdated)),
                    );
                  },
                  child: Text(t.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _resetPin() async {
    final t = AppLocalizations.of(context)!;

    await ManagerDao.savePin("0000");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.pinReset)),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.storeProfile,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _storeNameController,
            decoration: InputDecoration(
              labelText: t.storeName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickLogo,
                  icon: const Icon(Icons.image),
                  label: Text(t.chooseLogo),
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

          Text(
            t.inventorySettings,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _lowStockController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: t.lowStockThreshold,
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            t.managerPin,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          FutureBuilder<bool>(
            future: ManagerDao.hasPin(),
            builder: (context, snapshot) {
              final hasPin = snapshot.data ?? false;

              return ListTile(
                title: Text(t.currentPin),
                subtitle: Text(hasPin ? "****" : t.noPinSet),
                trailing: ElevatedButton(
                  onPressed: _changePinDialog,
                  child: Text(t.changePin),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: _resetPin,
            child: Text(t.resetPinTo0000),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _saveStoreInfo,
            child: Text(t.saveProfile),
          ),
        ],
      ),
    );
  }
}
