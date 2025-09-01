import 'package:go_router/go_router.dart';
import '../features/vpn/presentation/pages/vpn_home_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const VpnHomePage(),
    ),
  ],
);
