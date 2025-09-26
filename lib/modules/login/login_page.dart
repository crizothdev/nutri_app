import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/login/login_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller =
      AppBindings.I.get<LoginController>(() => LoginController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<LoginController>(
      state: controller,
      isLoading: controller.isLoading,
      builder: (context, state) {
        return Container();
      },
    );
  }
}
