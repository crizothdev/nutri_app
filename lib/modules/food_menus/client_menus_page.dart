import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/client.dart';
import 'package:nutri_app/modules/food_menus/client_menus_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class ClientMenusPage extends StatefulWidget {
  final Client client;
  const ClientMenusPage({super.key, required this.client});

  @override
  State<ClientMenusPage> createState() => _ClientMenusPageState();
}

class _ClientMenusPageState extends State<ClientMenusPage> {
  final controller = ClientMenusController();
  Client get client => widget.client;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<ClientMenusController>(
      state: controller,
      isLoading: controller.isLoading,
      builder: (context, state) {
        return Center(
          child: Text('Menus for ${client.name}'),
        );
      },
    );
  }
}
