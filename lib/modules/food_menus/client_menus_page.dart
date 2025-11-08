import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/client.dart';
import 'package:nutri_app/core/models/menu.dart';
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
  void initState() {
    controller.fetchMenus(client.id ?? 0);
    super.initState();
  }

  createNewMenu(Client client) {
    // abrir modal com o nome do menu e seguir para a pagina de ediçao de cardapio

    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('Criar novo cardápio para ${client.name}'),
            content: TextField(
              decoration: InputDecoration(
                labelText: 'Nome do Cardápio',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Lógica para criar o novo cardápio
                  final newMenu = Menu(
                    title:
                        'Nome do Cardápio', // Substituir pelo valor do TextField
                    id: client.id,
                  );
                  controller.createAndEditMenu(newMenu);
                  Navigator.of(context).pop();
                },
                child: Text('Criar'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<ClientMenusController>(
      state: controller,
      isLoading: controller.isLoading,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação ao pressionar o botão de adicionar novo cardápio
          createNewMenu(client);
        },
        backgroundColor: const Color(0xFF4B6B36),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      builder: (context, state) {
        if (state.menus.isEmpty) {
          return Center(
            child: Text('Nenhum menu cadastrado ainda para ${client.name}'),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            itemCount: state.menus.length,
            itemBuilder: (context, index) {
              final menu = state.menus[index];
              return MenuCard(menu: menu);
            },
          ),
        );
      },
    );
  }
}

class MenuCard extends StatelessWidget {
  final Menu menu;
  const MenuCard({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(menu.title ?? '',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Icon(Icons.chevron_right, color: Colors.grey)
        ],
      ),
    );
  }
}
