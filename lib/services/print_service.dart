import 'print_service_stub.dart'
    if (dart.library.html) 'print_service_web.dart';

Future<void> printUrls(List<String> urls) {
  return printUrlsImpl(urls);
}
