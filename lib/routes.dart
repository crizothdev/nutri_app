import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/client.dart';
import 'package:nutri_app/core/models/user.dart';
import 'package:nutri_app/modules/food_menus/client_menus_page.dart';
import 'package:nutri_app/modules/home/home_page.dart';
import 'package:nutri_app/modules/login/login_page.dart';
import 'package:nutri_app/modules/login/splash_page.dart';
import 'package:nutri_app/modules/my_clients/my_clients_page.dart';
import 'package:nutri_app/modules/my_clients/clients_detail.dart';
import 'package:nutri_app/modules/profile/profile_page.dart';
import 'package:nutri_app/modules/schedules/new_schedule_page.dart';
import 'package:nutri_app/modules/schedules/schedules_page.dart';
import 'package:nutri_app/modules/signup/signup_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String _SplashRoute = '/';
const String _LoginRoute = '/login';
const String _HomeRoute = '/home';
const String _MyClientsRoute = '/myclients';
const String _ProfileRoute = '/profile';
const String _SignupRoute = '/signup';
const String _FoodMenusRoute = '/foodmenus';
const String _clientMenusRoute = '/clientmenus';
const String _ClientsDetailRoute = '/clientDetail';
const String _newSchedulePage = '/newSchedule';
const String _schedulesPage = '/schedules';

final routes = {
  _SplashRoute: (context) => const SplashPage(),
  _HomeRoute: (context) {
    final user = ModalRoute.of(context)!.settings.arguments as User?;
    return HomePage(user: user);
  },
  _LoginRoute: (context) => const LoginPage(),
  _MyClientsRoute: (context) => const MyClientsPage(),
  _ClientsDetailRoute: (context) => ClientsDetail(
      client: ModalRoute.of(context)!.settings.arguments as Client),
  _clientMenusRoute: (context) => ClientMenusPage(
      client: ModalRoute.of(context)!.settings.arguments as Client),
  _ProfileRoute: (context) => const ProfilePage(),
  _SignupRoute: (context) => const SignupPage(),
  // _FoodMenusRoute: (context) => const FoodMenusPage(),
  _schedulesPage: (context) => const SchedulesPage(),
  _newSchedulePage: (context) => NewSchedulePage(
      selectedDate: ModalRoute.of(context)!.settings.arguments as DateTime),
};

void goHome([User? user]) {
  navigatorKey.currentState?.pushReplacementNamed(_HomeRoute, arguments: user);
}

void goLogin() {
  navigatorKey.currentState?.pushReplacementNamed(_LoginRoute);
}

void goFoodMenus() {
  navigatorKey.currentState?.pushNamed(_FoodMenusRoute);
}

void goMyClients() {
  navigatorKey.currentState?.pushNamed(_MyClientsRoute);
}

void goSchedules() {
  navigatorKey.currentState?.pushNamed(_schedulesPage);
}

void goClientsDetail(Client client) {
  navigatorKey.currentState?.pushNamed(_ClientsDetailRoute, arguments: client);
}

void goClientMenus(Client client) {
  navigatorKey.currentState?.pushNamed(_clientMenusRoute, arguments: client);
}

void goProfile() {
  navigatorKey.currentState?.pushNamed(_ProfileRoute);
}

void goSignup() {
  navigatorKey.currentState?.pushNamed(_SignupRoute);
}

void goNewSchedule(DateTime date) {
  navigatorKey.currentState?.pushNamed(_newSchedulePage, arguments: date);
}

void goBack() {
  navigatorKey.currentState?.pop();
}
