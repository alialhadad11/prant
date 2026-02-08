import 'package:flutter/material.dart';

import '../services/printer_prefs.dart';
import '../services/printer_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _printers = [];
  bool _loading = true;
  String? _error;
  String? _colorPrinter;
  String? _monoPrinter;

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  Future<void> _loadPrinters() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final printers = await getInstalledPrinters();
      final saved = await PrinterPrefs.load();
      setState(() {
        _printers
          ..clear()
          ..addAll(printers);
        _colorPrinter = _selectPrinter(saved.color);
        _monoPrinter = _selectPrinter(saved.mono);
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
        _error = 'Failed to load printers.';
      });
    }
  }

  String? _selectPrinter(String? saved) {
    if (_printers.isEmpty) {
      return null;
    }
    if (saved != null && _printers.contains(saved)) {
      return saved;
    }
    return _printers.first;
  }

  Future<void> _saveColorPrinter(String? value) async {
    setState(() => _colorPrinter = value);
    await PrinterPrefs.save(color: value);
  }

  Future<void> _saveMonoPrinter(String? value) async {
    setState(() => _monoPrinter = value);
    await PrinterPrefs.save(mono: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Printer Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select printers for each print mode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: _loadPrinters,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh printers',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent))
            else if (_printers.isEmpty)
              const Text('No printers found on this device.')
            else ...[
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Color printer',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _colorPrinter,
                    isExpanded: true,
                    items: _printers
                        .map(
                          (printer) => DropdownMenuItem(
                            value: printer,
                            child: Text(printer),
                          ),
                        )
                        .toList(),
                    onChanged: _saveColorPrinter,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Black & white printer',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _monoPrinter,
                    isExpanded: true,
                    items: _printers
                        .map(
                          (printer) => DropdownMenuItem(
                            value: printer,
                            child: Text(printer),
                          ),
                        )
                        .toList(),
                    onChanged: _saveMonoPrinter,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Printers are loaded from Windows installed printers.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
