import 'package:flutter/material.dart';
import 'package:nutri_app/modules/food_menus/food_menus_page.dart';
import 'package:nutri_app/modules/home/home_page.dart';
import 'package:nutri_app/modules/login/login_page.dart';
import 'package:nutri_app/modules/login/splash_page.dart';
import 'package:nutri_app/modules/my_clients/my_clients_page.dart';
import 'package:nutri_app/modules/my_clients/clients_detail.dart';
import 'package:nutri_app/modules/profile/profile_page.dart';
import 'package:nutri_app/modules/signup/signup_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String _SplashRoute = '/';
const String _LoginRoute = '/login';
const String _HomeRoute = '/home';
const String _MyClientsRoute = '/myclients';
const String _ProfileRoute = '/profile';
const String _SignupRoute = '/signup';
const String _FoodMenusRoute = '/foodmenus';
const String _ClientsDetailRoute = '/clientDetail';


final routes = {
  _SplashRoute: (context) => const SplashPage(),
  _HomeRoute: (context) => const HomePage(),
  _LoginRoute: (context) => const LoginPage(),
  _MyClientsRoute: (context) => const MyClientsPage(),
  _ClientsDetailRoute: (context) => const ClientsDetail(),
  _ProfileRoute: (context) => const ProfilePage(),
  _SignupRoute: (context) => const SignupPage(),
  _FoodMenusRoute: (context) => const FoodMenusPage(),
};

void goHome() {
  navigatorKey.currentState?.pushReplacementNamed(_HomeRoute);
}

void goLogin() {
  navigatorKey.currentState?.pushNamed(_LoginRoute);
}

void goFoodMenus() {
  navigatorKey.currentState?.pushNamed(_FoodMenusRoute);
}

void goMyClients() {
  navigatorKey.currentState?.pushNamed(_MyClientsRoute);
}

void goClientsDetail() {
  navigatorKey.currentState?.pushNamed(_ClientsDetailRoute);
}

void goProfile() {
  navigatorKey.currentState?.pushNamed(_ProfileRoute);
}

void goSignup() {
  navigatorKey.currentState?.pushNamed(_SignupRoute);
}

void goBack() {
  navigatorKey.currentState?.pop();
}
