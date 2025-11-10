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

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    controller.fetchMenus(client.id ?? 0);

    super.initState();
  }

  createNewMenu(Client client, {bool isNew = false}) {
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
                    title: 'Nome do Cardápio', // pegue do TextField
                    // id: null  (não setar!)
                    // targetKcal: opcional
                    meals: const [],
                  );
                  Navigator.of(context).pop();
                  controller.createAndEditMenu(newMenu, isNew: true);
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFCDB3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cardápios de ${client.name}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação ao pressionar o botão de adicionar novo cardápio
          createNewMenu(client, isNew: true);
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
              return MenuCard(
                menu: menu,
                onTapMenu: () {
                  controller.openOrEditMenu(menu);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class MenuCard extends StatelessWidget {
  final Menu menu;
  final Function() onTapMenu;
  const MenuCard({super.key, required this.menu, required this.onTapMenu});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapMenu,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 114, 143, 95),
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
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Icon(Icons.chevron_right, color: Colors.white)
          ],
        ),
      ),
    );
  }
}
