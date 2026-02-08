import 'package:shared_preferences/shared_preferences.dart';

class PrinterSelection {
  const PrinterSelection({this.color, this.mono});

  final String? color;
  final String? mono;
}

class PrinterPrefs {
  static const _colorKey = 'color_printer';
  static const _monoKey = 'mono_printer';

  static Future<PrinterSelection> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PrinterSelection(
      color: prefs.getString(_colorKey),
      mono: prefs.getString(_monoKey),
    );
  }

  static Future<void> save({String? color, String? mono}) async {
    final prefs = await SharedPreferences.getInstance();
    if (color != null) {
      await prefs.setString(_colorKey, color);
    }
    if (mono != null) {
      await prefs.setString(_monoKey, mono);
    }
  }
}
