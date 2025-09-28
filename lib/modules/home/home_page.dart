import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/home/home_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = AppBindings.I.get<HomeController>(() => HomeController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<HomeController>(
      state: controller,
      isLoading: controller.isLoading,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text(
          'Nutrify',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(Colors.white), // cor de fundo
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(100), // cantos arredondados
                ),
              ),
            ),
            onPressed: () {},
            icon: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            ),
          )
        ],
      ),
      builder: (context, state) {
        return Container();
      },
    );
  }
}
