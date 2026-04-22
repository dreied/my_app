import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../generated/app_localizations.dart';
import '../utils/pin_guard.dart';

class TrashBinPage extends StatefulWidget {
  const TrashBinPage({super.key});

  @override
  State<TrashBinPage> createState() => _TrashBinPageState();
}

class _TrashBinPageState extends State<TrashBinPage> {
  final ProductController _controller = ProductController();
  List<Product> _deleted = [];
  final Set<int> _selected = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    loading = true;
    setState(() {});

    _deleted = await _controller.loadDeletedProducts();
    _selected.clear();

    loading = false;
    setState(() {});
  }

  Future<void> _restore(Product p) async {
    final t = AppLocalizations.of(context)!;

    if (!await requireManagerPin(context)) return;

    await _controller.restoreProduct(p.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${p.name} ${t.restoredSuccessfully}")),
    );

    _load();
  }

  Future<void> _deleteForever(Product p) async {
    final t = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteForever),
        content: Text("${t.delete} ${p.name}?"),
        actions: [
          TextButton(
            child: Text(t.cancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text(t.delete),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!await requireManagerPin(context)) return;

    await _controller.deleteForever(p.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${p.name} ${t.deletedForeverSuccessfully}")),
    );

    _load();
  }

  Future<void> _restoreAll() async {
    final t = AppLocalizations.of(context)!;

    if (_deleted.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.restoreAll),
        content: Text(t.confirmRestoreAll),
        actions: [
          TextButton(
            child: Text(t.cancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text(t.restoreAll),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!await requireManagerPin(context)) return;

    for (final p in _deleted) {
      await _controller.restoreProduct(p.id!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.restoredSuccessfully)),
    );

    _load();
  }

  Future<void> _deleteAllForever() async {
    final t = AppLocalizations.of(context)!;

    if (_deleted.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteAllForever),
        content: Text(t.confirmDeleteAllForever),
        actions: [
          TextButton(
            child: Text(t.cancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text(t.delete),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!await requireManagerPin(context)) return;

    for (final p in _deleted) {
      await _controller.deleteForever(p.id!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.deletedForeverSuccessfully)),
    );

    _load();
  }

  Future<void> _bulkRestore() async {
    final t = AppLocalizations.of(context)!;

    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.nothingSelected)),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.bulkRestore),
        content: Text(t.confirmBulkRestore),
        actions: [
          TextButton(
            child: Text(t.cancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text(t.restore),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!await requireManagerPin(context)) return;

    for (final id in _selected) {
      await _controller.restoreProduct(id);
    }

    _selected.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.bulkRestoredSuccessfully)),
    );

    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.trashBin),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_page),
            tooltip: t.restoreAll,
            onPressed: _restoreAll,
          ),
          IconButton(
            icon: const Icon(Icons.restore_from_trash),
            tooltip: t.bulkRestore,
            onPressed: _bulkRestore,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: t.deleteAllForever,
            onPressed: _deleteAllForever,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _deleted.isEmpty
              ? Center(
                  child: Text(
                    t.noDeletedProducts,
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _deleted.length,
                  itemBuilder: (_, i) {
                    final p = _deleted[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Checkbox(
                          value: _selected.contains(p.id),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selected.add(p.id!);
                              } else {
                                _selected.remove(p.id);
                              }
                            });
                          },
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text("Barcode: ${p.barcode}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore,
                                  color: Colors.green),
                              onPressed: () => _restore(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.red),
                              onPressed: () => _deleteForever(p),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
