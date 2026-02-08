import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config.dart';
import '../services/local_host.dart';
import '../services/order_processor.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  final _random = Random();
  Timer? _timer;
  OrderProcessor? _orderProcessor;
  String _token = '';
  DateTime _nextRefresh = DateTime.now();
  String _host = 'localhost';
  String _orderStatus = 'Waiting for orders...';

  @override
  void initState() {
    super.initState();
    _loadHost();
    _refreshToken();
    _orderProcessor = OrderProcessor(
      onStatus: (status) => setState(() => _orderStatus = status),
    )..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (DateTime.now().isAfter(_nextRefresh)) {
        _refreshToken();
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _orderProcessor?.stop();
    super.dispose();
  }

  void _refreshToken() {
    final part = List.generate(6, (_) => _random.nextInt(10)).join();
    _token = '${DateTime.now().millisecondsSinceEpoch}-$part';
    _nextRefresh = DateTime.now().add(qrRefreshEvery);
    setState(() {});
  }

  Future<void> _loadHost() async {
    final host = await resolveLocalHost();
    if (!mounted) {
      return;
    }
    setState(() => _host = host);
  }

  Duration get _remaining => _nextRefresh.difference(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final orderUrl = buildOrderUrl(_host, _token);
    final remaining = _remaining.isNegative ? Duration.zero : _remaining;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prntat Desktop'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Scan the barcode to open the mobile order page',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: orderUrl,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  orderUrl,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Refreshes in ${remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Text(
                  _orderStatus,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _refreshToken,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
