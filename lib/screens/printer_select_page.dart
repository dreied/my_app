import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../services/receipt_service.dart';
import '../generated/app_localizations.dart';

class PrinterSelectPage extends StatefulWidget {
  const PrinterSelectPage({super.key});

  @override
  State<PrinterSelectPage> createState() => _PrinterSelectPageState();
}

class _PrinterSelectPageState extends State<PrinterSelectPage> {
  List<BluetoothDevice> devices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final list = await ReceiptService.bluetooth.getBondedDevices();
      setState(() {
        devices = list;
        loading = false;
      });
    } catch (e) {
      setState(() {
        devices = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.selectPrinter)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? Center(child: Text(t.noPrinterConfigured))
              : ListView(
                  children: devices.map((d) {
                    return ListTile(
                      title: Text(d.name ?? t.unknown),
                      subtitle: Text(d.address ?? ""),
                      onTap: () async {
                        await ReceiptService.savePrinter(d);
                        Navigator.pop(context, d); // return selected device
                      },
                    );
                  }).toList(),
                ),
    );
  }
}
