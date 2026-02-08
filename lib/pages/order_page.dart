import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/number_field.dart';
import '../widgets/price_field.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _copies = 1;
  int _pages = 1;
  bool _isColor = true;
  double _pricePerPageColor = 1.0;
  double _pricePerPageMono = 0.5;
  bool _uploading = false;
  int _uploadedCount = 0;
  String? _uploadError;
  bool _submitting = false;
  String? _submitError;
  String? _submitSuccess;
  List<String> _uploadedPaths = [];

  Future<void> _pickAndUploadFiles(String token) async {
    setState(() {
      _uploading = true;
      _uploadedCount = 0;
      _uploadError = null;
      _submitError = null;
      _submitSuccess = null;
      _uploadedPaths = [];
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );
      if (result == null) {
        setState(() => _uploading = false);
        return;
      }

      final storage = Supabase.instance.client.storage.from('orders');
      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) {
          continue;
        }
        final path = '$token/${file.name}';
        await storage.uploadBinary(path, bytes);
        setState(() {
          _uploadedCount += 1;
          _uploadedPaths.add(path);
        });
      }
    } catch (error) {
      setState(() => _uploadError = 'Upload failed.');
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _submitOrder(String token, double total) async {
    if (_uploadedPaths.isEmpty) {
      setState(() => _submitError = 'Upload files first.');
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = null;
      _submitSuccess = null;
    });

    try {
      await Supabase.instance.client.from('orders').insert({
        'token': token,
        'file_paths': _uploadedPaths,
        'is_color': _isColor,
        'copies': _copies,
        'pages': _pages,
        'total': total,
        'status': 'new',
      });
      setState(() => _submitSuccess = 'Order sent to desktop printer.');
    } catch (error) {
      setState(() => _submitError = 'Failed to send order.');
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final token = uri.queryParameters['token'] ?? 'unknown';
    final pricePerPage = _isColor ? _pricePerPageColor : _pricePerPageMono;
    final total = _copies * _pages * pricePerPage;
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Order')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order token: $token',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload files',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _uploading
                      ? null
                      : () => _pickAndUploadFiles(token),
                  icon: const Icon(Icons.upload_file),
                  label: Text(_uploading ? 'Uploading...' : 'Choose files'),
                ),
                if (_uploadedCount > 0) ...[
                  const SizedBox(height: 8),
                  Text('Uploaded: $_uploadedCount'),
                ],
                if (_uploadError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _uploadError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                if (_submitError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _submitError!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                if (_submitSuccess != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _submitSuccess!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: NumberField(
                        label: 'Pages',
                        value: _pages,
                        onChanged: (value) => setState(() => _pages = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NumberField(
                        label: 'Copies',
                        value: _copies,
                        onChanged: (value) => setState(() => _copies = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Color printing'),
                  value: _isColor,
                  onChanged: (value) => setState(() => _isColor = value),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PriceField(
                        label: 'Color price / page',
                        value: _pricePerPageColor,
                        onChanged: (value) =>
                            setState(() => _pricePerPageColor = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PriceField(
                        label: 'Mono price / page',
                        value: _pricePerPageMono,
                        onChanged: (value) =>
                            setState(() => _pricePerPageMono = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  color: Colors.blueGrey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Invoice preview',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Pages: $_pages'),
                        Text('Copies: $_copies'),
                        Text('Mode: ${_isColor ? 'Color' : 'Black & white'}'),
                        const SizedBox(height: 8),
                        Text(
                          'Total: ${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _uploading || _submitting
                      ? null
                      : () => _submitOrder(token, total),
                  icon: const Icon(Icons.print),
                  label: Text(
                    _submitting ? 'Sending...' : 'Send to desktop printer',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
