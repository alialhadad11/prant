import 'local_host_stub.dart' if (dart.library.io) 'local_host_io.dart';

Future<String> resolveLocalHost() {
  return resolveLocalHostImpl();
}
