import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/profile/profile_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final controller =
      AppBindings.I.get<ProfileController>(() => ProfileController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<ProfileController>(
      state: controller,
      builder: (context, state) {
        return Container();
      },
    );
  }
}
