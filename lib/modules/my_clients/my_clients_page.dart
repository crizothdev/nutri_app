import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/my_clients/my_clientes_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class MyClientsPage extends StatefulWidget {
  const MyClientsPage({super.key});

  @override
  State<MyClientsPage> createState() => _MyClientsPageState();
}

class _MyClientsPageState extends State<MyClientsPage> {
  final controller =
      AppBindings.I.get<MyClientsController>(() => MyClientsController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<MyClientsController>(
      state: controller,
      isLoading: controller.isLoading,
      builder: (context, state) {
        return Container();
      },
    );
  }
}
