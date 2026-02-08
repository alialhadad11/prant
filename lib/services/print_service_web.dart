import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

Future<void> printUrlsImpl(List<String> urls) async {
  for (final url in urls) {
    final completer = Completer<void>();
    final iframe = html.IFrameElement()
      ..style.display = 'none'
      ..src = url;

    iframe.onLoad.first.then((_) async {
      try {
        final contentWindow = iframe.contentWindow;
        if (contentWindow != null) {
          js_util.callMethod(contentWindow, 'print', const []);
        }
      } finally {
        iframe.remove();
        completer.complete();
      }
    });

    html.document.body?.append(iframe);
    await completer.future;
  }
}
