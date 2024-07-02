import 'package:auto_route/auto_route.dart';
import 'package:baFia/views/login_page.dart';
import 'package:baFia/views/dashboard_page.dart';
import 'package:baFia/views/item_page.dart';
import 'package:baFia/views/profile_page.dart';
import 'package:baFia/views/about_page.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(page: LoginPage, initial: true),
    AutoRoute(page: DashboardPage),
    AutoRoute(page: ItemPage),
    AutoRoute(page: ProfilePage),
    AutoRoute(page: AboutPage),
  ],
)
class $AppRouter {}
