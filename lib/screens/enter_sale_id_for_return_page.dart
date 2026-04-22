import 'package:flutter/material.dart';
import 'return_sale_page.dart';
import '../generated/app_localizations.dart';

class EnterSaleIdForReturnPage extends StatefulWidget {
  const EnterSaleIdForReturnPage({super.key});

  @override
  State<EnterSaleIdForReturnPage> createState() => _EnterSaleIdForReturnPageState();
}

class _EnterSaleIdForReturnPageState extends State<EnterSaleIdForReturnPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.returnItems)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              t.enterSaleId,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.saleId,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.isEmpty) return;

                  final id = int.tryParse(_controller.text);
                  if (id == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReturnSalePage(saleId: id),
                    ),
                  );
                },
                child: Text(t.search),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
