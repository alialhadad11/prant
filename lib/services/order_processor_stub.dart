import 'order_processor.dart';

class OrderProcessorImpl implements OrderProcessor {
  OrderProcessorImpl({required void Function(String) onStatus});

  @override
  void start() {}

  @override
  void stop() {}
}
