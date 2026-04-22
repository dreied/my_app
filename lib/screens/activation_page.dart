import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/activation_service.dart';
import '../generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class ActivationPage extends StatefulWidget {
  const ActivationPage({super.key});

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  String fingerprint = "";
  String code = "";
  bool activated = false;
  DateTime? expiry;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    fingerprint = await ActivationService.getFingerprint();
    activated = await ActivationService.isActivated();
    expiry = await ActivationService.getExpiryDate();
    setState(() {});
  }

  Future<void> _activate() async {
    final t = AppLocalizations.of(context)!;

    final ok = await ActivationService.validate(code);
    if (ok) {
      activated = true;
      expiry = await ActivationService.getExpiryDate();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.activationSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.activationFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(t.activation)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.deviceFingerprint, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),

              SelectableText(
                fingerprint,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: Text(t.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: fingerprint));
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
  icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
  label: const Text(
    "WhatsApp",
    style: TextStyle(color: Colors.white),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  ),
  onPressed: () {
    final phone = "963937749701"; // same number
    final message = Uri.encodeComponent(fingerprint); // send fingerprint
    final url = "https://wa.me/$phone?text=$message";

    launchUrl(Uri.parse(url));
  },
),

                ],
              ),

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: t.activationCode,
                  border: const OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 2,
                keyboardType: TextInputType.multiline,
                onChanged: (v) => code = v,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _activate,
                child: Text(t.activate),
              ),

              const SizedBox(height: 20),

              Text(
                activated ? t.activated : t.notActivated,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: activated ? Colors.green : Colors.red,
                ),
              ),

              if (activated && expiry != null)
                Text(
                  "${t.activationExpiry}: ${expiry!.toString().split(' ').first}",
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
