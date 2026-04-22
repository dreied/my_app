import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../db/customer_dao.dart';
import '../services/settings_service.dart';
import '../services/receipt_service.dart';
import '../services/backup_service.dart';
import '../utils/pin_guard.dart';
import '../screens/printer_select_page.dart';
import '../screens/activation_page.dart';
import '../generated/app_localizations.dart';
import '../services/activation_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settings = SettingsService.instance;

  @override
  void initState() {
    super.initState();
    ReceiptService.loadSavedPrinter();
  }

  // PRINTER
  Future<void> _selectPrinter() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrinterSelectPage()),
    );

    if (selected != null) {
      await _settings.setPrinter(
        name: selected.name ?? "Unknown",
        mac: selected.address ?? "",
      );

      await ReceiptService.savePrinter(selected);
      setState(() {});
    }
  }

  Future<void> _clearPrinter() async {
    await _settings.clearPrinter();
    ReceiptService.selectedDevice = null;

    if (!mounted) return;
    final t = AppLocalizations.of(context)!;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.printerRemoved)),
    );
  }

  // BACKUP
  Future<void> _pickBackupFolder() async {
    final folder = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Choose Backup Folder",
    );
    if (folder != null) {
      await _settings.setBackupFolder(folder);
      setState(() {});
    }
  }

  Future<void> _createBackup() async {
    final t = AppLocalizations.of(context)!;

    if (_settings.backupFolder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.backupFolder)),
      );
      return;
    }

    if (!await requireManagerPin(context)) return;

    try {
      final path =
          await BackupService.createBackupToFolder(_settings.backupFolder, t);
      await _settings.setLastBackupDate(DateTime.now().toIso8601String());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.backupSuccessMessage}\n$path")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.backupFailed}: $e")),
      );
    }
  }

  Future<void> _restoreBackup() async {
    final t = AppLocalizations.of(context)!;

    if (_settings.backupFolder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.backupFolder)),
      );
      return;
    }

    if (!await requireManagerPin(context)) return;

    final backups =
        await BackupService.listBackupsInFolder(_settings.backupFolder);

    if (backups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.backupFailed)),
      );
      return;
    }

    // Modern Material 3 bottom sheet for restore
    // Each backup in a single row
    // High-contrast, clean layout
    // Only logic preserved
    // -----------------------------
    // Restore bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t.restoreBackup,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: backups.length,
                  itemBuilder: (_, i) {
                    final file = backups[i];
                    final name = file.path.split("/").last;

                    return ListTile(
                      leading: const Icon(Icons.storage, color: Colors.blue),
                      title: Text(name),
                      trailing:
                          const Icon(Icons.restore, color: Colors.green),
                      onTap: () async {
                        Navigator.pop(context);
                        await BackupService.restoreBackup(file.path, t);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.backupSuccess)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // CUSTOMER RESET
  Future<void> _resetAllCustomersDialog() async {
    final t = AppLocalizations.of(context)!;

    if (!await requireManagerPin(context)) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.resetAllCustomers),
        content: Text(t.confirmResetAllCustomers),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.reset),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await CustomerDao().resetAllCustomersToInitial();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.allCustomersReset)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final printerName = _settings.printerName;
    final printerMac = _settings.printerMac;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(t.settings),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 40,
        ),
        children: [
          // Use ExpansionPanelList.radio for Material 3 feel
          // Only one open at a time automatically
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionPanelList.radio(
              elevation: 0,
              expandedHeaderPadding: EdgeInsets.zero,
              materialGapSize: 12,
              animationDuration: const Duration(milliseconds: 200),
              children: [
                // ACTIVATION PANEL
                ExpansionPanelRadio(
                  value: 0,
                  canTapOnHeader: true,
                  backgroundColor: colorScheme.surface,
                  headerBuilder: (context, isExpanded) {
                    return _panelHeader(
                      icon: Icons.lock,
                      label: t.activation,
                      isExpanded: isExpanded,
                      colorScheme: colorScheme,
                    );
                  },
                  body: _outlinedPanelBody(
                    colorScheme: colorScheme,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.lock_outline,
                                color: colorScheme.primary),
                            title: Text(t.activation),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ActivationPage()),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder(
                            future: ActivationService.isActivated(),
                            builder: (context, snapshot) {
                              final active = snapshot.data == true;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.green
                                      : colorScheme.error,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  active ? t.activated : t.notActivated,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // PRINTER PANEL
                ExpansionPanelRadio(
                  value: 1,
                  canTapOnHeader: true,
                  backgroundColor: colorScheme.surface,
                  headerBuilder: (context, isExpanded) {
                    return _panelHeader(
                      icon: Icons.print,
                      label: t.printer,
                      isExpanded: isExpanded,
                      colorScheme: colorScheme,
                    );
                  },
                  body: _outlinedPanelBody(
                    colorScheme: colorScheme,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            printerMac.isEmpty
                                ? t.noPrinter
                                : "${t.savedPrinter}:\n$printerName\n${t.mac}: $printerMac",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.print),
                                label: Text(t.selectPrinter),
                                onPressed: _selectPrinter,
                              ),
                              const SizedBox(width: 12),
                              if (printerMac.isNotEmpty)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  icon: const Icon(Icons.delete),
                                  label: Text(t.removePrinter),
                                  onPressed: _clearPrinter,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // BACKUP PANEL
                ExpansionPanelRadio(
                  value: 2,
                  canTapOnHeader: true,
                  backgroundColor: colorScheme.surface,
                  headerBuilder: (context, isExpanded) {
                    return _panelHeader(
                      icon: Icons.backup,
                      label: t.backupTitle,
                      isExpanded: isExpanded,
                      colorScheme: colorScheme,
                    );
                  },
                  body: _outlinedPanelBody(
                    colorScheme: colorScheme,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                            future: BackupService.getBackupSize(
                                _settings.backupFolder),
                            builder: (context, snapshot) {
                              final size = snapshot.data ?? "0 KB";
                              final lastDate =
                                  _settings.lastBackupDate.isEmpty
                                      ? t.noBackupYet
                                      : _settings.lastBackupDate
                                          .split("T")
                                          .first;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${t.backupSize}: $size"),
                                  Text("${t.lastBackup}: $lastDate"),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(t.backupFolder),
                            subtitle: Text(
                              _settings.backupFolder.isEmpty
                                  ? t.noBackupFolder
                                  : _settings.backupFolder,
                            ),
                            trailing: const Icon(Icons.folder),
                            onTap: _pickBackupFolder,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.backup),
                                label: Text(t.createBackup),
                                onPressed: _createBackup,
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.restore),
                                label: Text(t.restoreBackup),
                                onPressed: _restoreBackup,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(t.automaticBackup),
                            value: _settings.autoBackup,
                            onChanged: (value) async {
                              await _settings.setAutoBackup(value);
                              setState(() {});
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(t.backupFrequency),
                            subtitle: Text(_settings.backupFrequency),
                            trailing: const Icon(Icons.arrow_drop_down),
                            onTap: () {
                              // Modern bottom sheet for frequency selection
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (_) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade400,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          t.backupFrequency,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ListTile(
                                          leading: const Icon(
                                              Icons.calendar_today),
                                          title: Text(t.daily),
                                          onTap: () async {
                                            await _settings
                                                .setBackupFrequency(t.daily);
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              const Icon(Icons.date_range),
                                          title: Text(t.weekly),
                                          onTap: () async {
                                            await _settings
                                                .setBackupFrequency(t.weekly);
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                              Icons.calendar_month),
                                          title: Text(t.monthly),
                                          onTap: () async {
                                            await _settings
                                                .setBackupFrequency(t.monthly);
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // CUSTOMER MAINTENANCE PANEL
                ExpansionPanelRadio(
                  value: 3,
                  canTapOnHeader: true,
                  backgroundColor: colorScheme.surface,
                  headerBuilder: (context, isExpanded) {
                    return _panelHeader(
                      icon: Icons.people,
                      label: t.customerMaintenance,
                      isExpanded: isExpanded,
                      colorScheme: colorScheme,
                    );
                  },
                  body: _outlinedPanelBody(
                    colorScheme: colorScheme,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.refresh),
                        title: Text(t.resetAllCustomers),
                        subtitle: Text(t.resetAllCustomersSubtitle),
                        onTap: _resetAllCustomersDialog,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelHeader({
    required IconData icon,
    required String label,
    required bool isExpanded,
    required ColorScheme colorScheme,
  }) {
    final primary = colorScheme.primary;
    final onSurface = colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(
            icon,
            color: isExpanded ? primary : onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isExpanded ? primary : onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlinedPanelBody({
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary,
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}
