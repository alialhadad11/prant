import 'dart:io';
import 'dart:ffi';

import 'package:win32/win32.dart';

Future<void> printFileToPrinterImpl({
  required String filePath,
  String? printerName,
}) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('File not found for printing.');
  }

  final operation = printerName == null ? 'print' : 'printto';
  final args = printerName == null ? nullptr : TEXT('"$printerName"');
  final result = ShellExecute(
    0,
    TEXT(operation),
    TEXT(filePath),
    args,
    nullptr,
    SW_HIDE,
  );

  if (result <= 32) {
    throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
  }
}
