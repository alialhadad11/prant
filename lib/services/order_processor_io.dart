import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'order_processor.dart';
import 'printer_prefs.dart';
import 'print_file_service.dart';

class OrderProcessorImpl implements OrderProcessor {
  OrderProcessorImpl({required void Function(String) onStatus})
    : _onStatus = onStatus;

  final void Function(String) _onStatus;
  Timer? _timer;
  bool _busy = false;

  @override
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _tick());
    _tick();
  }

  @override
  void stop() {
    _timer?.cancel();
  }

  Future<void> _tick() async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      await _processOrders();
    } finally {
      _busy = false;
    }
  }

  Future<void> _processOrders() async {
    if (!Platform.isWindows) {
      return;
    }

    final client = Supabase.instance.client;
    final response = await client
        .from('orders')
        .select()
        .eq('status', 'new')
        .order('created_at');

    if (response is! List) {
      return;
    }

    for (final row in response) {
      if (row is Map<String, dynamic>) {
        await _processOrder(row);
      }
    }
  }

  Future<void> _processOrder(Map<String, dynamic> order) async {
    final client = Supabase.instance.client;
    final id = order['id']?.toString();
    if (id == null) {
      return;
    }

    final paths = _toStringList(order['file_paths']);
    if (paths.isEmpty) {
      await _markFailed(id, 'No files found.');
      return;
    }

    await client.from('orders').update({'status': 'processing'}).eq('id', id);
    _onStatus('Printing order $id');

    try {
      final prefs = await PrinterPrefs.load();
      final isColor = order['is_color'] as bool? ?? true;
      final copies = (order['copies'] as int?) ?? 1;
      final printerName = isColor ? prefs.color : prefs.mono;

      if (printerName == null || printerName.isEmpty) {
        throw Exception('Printer not selected.');
      }

      final tempDir = await Directory.systemTemp.createTemp('prntat');
      final storage = client.storage.from('orders');

      for (final path in paths) {
        final url = await storage.createSignedUrl(path, 300);
        final filePath = await _downloadToFile(url, tempDir.path);
        for (var i = 0; i < copies; i++) {
          await printFileToPrinter(
            filePath: filePath,
            printerName: printerName,
          );
        }
      }

      await client.from('orders').update({'status': 'printed'}).eq('id', id);
      _onStatus('Printed order $id');
    } catch (error) {
      await _markFailed(id, 'Print failed.');
      _onStatus('Failed order $id');
    }
  }

  Future<void> _markFailed(String id, String message) async {
    final client = Supabase.instance.client;
    await client
        .from('orders')
        .update({'status': 'error', 'error_message': message})
        .eq('id', id);
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  Future<String> _downloadToFile(String url, String dir) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Download failed.');
    }

    final fileName = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : DateTime.now().millisecondsSinceEpoch.toString();
    final filePath = '$dir/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }
}
