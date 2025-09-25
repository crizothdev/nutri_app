import 'package:flutter/material.dart';
import 'package:nutri_app/modules/food_menus/food_menus_page.dart';
import 'package:nutri_app/modules/home/home_page.dart';
import 'package:nutri_app/modules/login/login_page.dart';
import 'package:nutri_app/modules/my_clients/my_clients_page.dart';
import 'package:nutri_app/modules/profile/profile_page.dart';
import 'package:nutri_app/modules/signup/signup_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final routes = {
  '/': (context) => const HomePage(),
  '/login': (context) => const LoginPage(),
  '/myclients': (context) => const MyClientsPage(),
  '/profile': (context) => const ProfilePage(),
  '/signup': (context) => const SignupPage(),
  '/foodmenus': (context) => const FoodMenusPage(),
};

void goHome() {
  navigatorKey.currentState?.pushReplacementNamed('/');
}

void goLogin() {
  navigatorKey.currentState?.pushNamed('/login');
}

void goFoodMenus() {
  navigatorKey.currentState?.pushNamed('/foodmenus');
}

void goMyClients() {
  navigatorKey.currentState?.pushNamed('/myclients');
}

void goProfile() {
  navigatorKey.currentState?.pushNamed('/profile');
}

void goSignup() {
  navigatorKey.currentState?.pushNamed('/signup');
}

void goBack() {
  navigatorKey.currentState?.pop();
}
