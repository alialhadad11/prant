import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _printers = ['Printer A', 'Printer B', 'Printer C'];
  String? _colorPrinter;
  String? _monoPrinter;

  @override
  void initState() {
    super.initState();
    _colorPrinter = _printers.first;
    _monoPrinter = _printers.last;
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
            const Text(
              'Select printers for each print mode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
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
                  onChanged: (value) => setState(() => _colorPrinter = value),
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
                  onChanged: (value) => setState(() => _monoPrinter = value),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'These are placeholders. Replace with real printer discovery.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
