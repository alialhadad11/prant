import 'printer_service_stub.dart'
    if (dart.library.io) 'printer_service_io.dart';

Future<List<String>> getInstalledPrinters() {
  return getInstalledPrintersImpl();
}
