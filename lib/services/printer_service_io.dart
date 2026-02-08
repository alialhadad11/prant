import 'dart:io';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

Future<List<String>> getInstalledPrintersImpl() async {
  if (!Platform.isWindows) {
    return [];
  }

  final flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;
  final pcbNeeded = calloc<DWORD>();
  final pcReturned = calloc<DWORD>();

  try {
    EnumPrinters(flags, nullptr, 4, nullptr, 0, pcbNeeded, pcReturned);
    if (pcbNeeded.value == 0) {
      return [];
    }

    final buffer = calloc<Uint8>(pcbNeeded.value);
    try {
      final success = EnumPrinters(
        flags,
        nullptr,
        4,
        buffer.cast(),
        pcbNeeded.value,
        pcbNeeded,
        pcReturned,
      );
      if (success == 0) {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }

      final printers = <String>[];
      final info = buffer.cast<PRINTER_INFO_4>();
      for (var i = 0; i < pcReturned.value; i++) {
        final entry = info.elementAt(i).ref;
        final name = entry.pPrinterName.toDartString();
        if (name.isNotEmpty) {
          printers.add(name);
        }
      }

      printers.sort();
      return printers;
    } finally {
      calloc.free(buffer);
    }
  } finally {
    calloc.free(pcbNeeded);
    calloc.free(pcReturned);
  }
}
