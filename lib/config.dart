const int webPort = 8080;
const Duration qrRefreshEvery = Duration(minutes: 3);

const String supabaseUrl = 'https://owmuesmincepgkvmgenw.supabase.co';
const String supabaseAnonKey = 'sb_publishable_1JmeTmVuaCUId_bgkWi5Kg_WumqSQcw';

const bool usePublicOrderUrl = true;
const String publicOrderBaseUrl =
    'https://alialhadad11.github.io/prant/#/order';

String buildOrderUrl(String host, String token) {
  if (usePublicOrderUrl) {
    return '$publicOrderBaseUrl?token=$token';
  }
  return 'http://$host:$webPort/#/order?token=$token';
}
