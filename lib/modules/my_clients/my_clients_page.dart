import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/client.dart';
import 'package:nutri_app/modules/my_clients/my_clientes_controller.dart';
import 'package:nutri_app/routes.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class MyClientsPage extends StatefulWidget {
  const MyClientsPage({super.key});

  @override
  State<MyClientsPage> createState() => _MyClientsPageState();
}

class _MyClientsPageState extends State<MyClientsPage> {
  final controller = MyClientsController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  createNewClient() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          final nameController = TextEditingController();
          final emailController = TextEditingController();
          final phoneController = TextEditingController();
          final weightController = TextEditingController();
          final heightController = TextEditingController();

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'E-mail'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Telefone'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Peso'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Altura'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.createClient(
                      Client(
                        name: nameController.text,
                        email: emailController.text,
                        phone: phoneController.text,
                        weight: weightController.text,
                        height: heightController.text,
                      ),
                    );
                  },
                  child: Text('Criar Cliente'),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<MyClientsController>(
      state: controller,
      isLoading: controller.isLoading,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text(
          'Meus Clientes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: () {
          createNewClient();
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              spacing: 12,
              children: [
                ClientCard(),
                ClientCard(),
                ClientCard(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ClientCard extends StatelessWidget {
  const ClientCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => goClientsDetail(),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.black)),
        child: Row(
          children: [
            CircleAvatar(),
            SizedBox(width: 10),
            Text('Cliente 1'),
          ],
        ),
      ),
    );
  }
}
