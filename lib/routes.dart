import 'package:fcm_task/screens/login_screen.dart';
import 'package:fcm_task/screens/welcome_screen.dart';
import 'package:get/get.dart';

class Routes {
  static String login = '/';
  static String welcome = '/welcome';
}

final getPages = [
  GetPage(
    name: Routes.login,
    page: () => const LoginScreen(),
  ),
  GetPage(
    name: Routes.welcome,
    page: () => const WelcomeScreen(),
  ),
];
