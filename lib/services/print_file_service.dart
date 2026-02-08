import 'print_file_service_stub.dart'
    if (dart.library.io) 'print_file_service_windows.dart';

Future<void> printFileToPrinter({
  required String filePath,
  String? printerName,
}) {
  return printFileToPrinterImpl(filePath: filePath, printerName: printerName);
}
