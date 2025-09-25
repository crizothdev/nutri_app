import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/signup/signup_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final controller =
      AppBindings.I.get<SignupController>(() => SignupController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<SignupController>(
      state: controller,
      builder: (context, state) {
        return Container();
      },
    );
  }
}
