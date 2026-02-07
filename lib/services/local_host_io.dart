import 'dart:io';

Future<String> resolveLocalHostImpl() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );

  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      if (!address.isLoopback && !address.isLinkLocal) {
        return address.address;
      }
    }
  }

  return 'localhost';
}
