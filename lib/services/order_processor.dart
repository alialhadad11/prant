import 'order_processor_stub.dart'
    if (dart.library.io) 'order_processor_io.dart';

abstract class OrderProcessor {
  factory OrderProcessor({required void Function(String) onStatus}) =
      OrderProcessorImpl;

  void start();
  void stop();
}
