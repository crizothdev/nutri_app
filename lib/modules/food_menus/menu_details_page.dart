import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/menu.dart';
import 'package:nutri_app/modules/food_menus/client_menus_controller.dart';
import 'package:nutri_app/modules/food_menus/meal_select_foods_page.dart';
import 'package:nutri_app/routes.dart';
import 'package:nutri_app/widgets/food_menus_details_widgets.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class MenuDetailsParams {
  final Menu menu;
  final bool isNewMenu;
  final ClientMenusController controller;
  MenuDetailsParams({
    required this.menu,
    required this.controller,
    this.isNewMenu = false,
  });
}

class MenuDetailPage extends StatefulWidget {
  final MenuDetailsParams params;
  const MenuDetailPage({super.key, required this.params});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  Menu get menu => widget.params.menu;
  late final ClientMenusController controller;
  late final int? menuId;

  // Controller para capturar screenshot da área do conteúdo
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    controller = widget.params.controller;
    menuId = widget.params.menu.id;
    // NÃO faça dispose do controller aqui
  }

  Menu? _findMenu() {
    return controller.menus.firstWhere(
      (m) => m.id == menuId,
      orElse: () => widget.params.menu, // fallback
    );
  }

  Future<void> _shareContentArea() async {
    try {
      // pixelRatio maior para imagem mais nítida
      final Uint8List? png =
          await _screenshotController.capture(pixelRatio: 2.0);
      if (png == null) return;

      // Cria XFile direto dos bytes (sem gravar em disco)
      final xfile = XFile.fromData(
        png,
        mimeType: 'image/png',
        name: 'menu_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
          text: 'Meu cardápio 🍽️',
        ),
      );
    } catch (e) {
      debugPrint('Erro ao compartilhar screenshot: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Não foi possível compartilhar o cardápio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<ClientMenusController>(
      state: controller,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.black),
            tooltip: 'Compartilhar print do cardápio',
            onPressed: _shareContentArea,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              // deletar o menu
              controller.deleteMenuFromUserOrFromBase(menu);
              Navigator.pop(context);
            },
          ),
        ],
        backgroundColor: const Color(0xFFBFCDB3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Refeições',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      builder: (context, state) {
        // Sempre buscar a versão "viva" do menu no controller,
        // pois meals podem ser alteradas durante a navegação
        final liveMenu = controller.menus.firstWhere(
          (m) => m.id == menu.id,
          orElse: () => menu,
        );

        if (liveMenu.meals.isEmpty) {
          return const Center(child: Text('Nenhuma refeição encontrada'));
        }

        // Envolvemos SOMENTE o conteúdo em Screenshot para capturar a lista, cards, etc.
        return Screenshot(
          controller: _screenshotController,
          child: Container(
            color: const Color(0xFFEFF2E9), // fundo consistente no print
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: liveMenu.meals.length,
                      itemBuilder: (context, index) {
                        final meal = liveMenu.meals[index];
                        return MealCard(
                          meal: meal,
                          onDelete: () {
                            if (menuId != null) {
                              controller.deleteMeal(
                                  meal: meal, menuId: menuId!);
                            } else {
                              liveMenu.meals.removeWhere((m) => m == meal);
                              controller.notifyListeners();
                            }
                          },
                          onEdit: () {
                            controller.cart = meal.foods;
                            createNewMeal();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewMeal();
        },
        backgroundColor: const Color(0xFF4C7C3D),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  void createNewMeal() {
    final mealNameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar nova refeição',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mealNameController,
                decoration: const InputDecoration(
                  labelText: 'Título da refeição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Importante: passar a referência "viva" do menu
                  final liveMenu = controller.menus.firstWhere(
                    (m) => m.id == menu.id,
                    orElse: () => menu,
                  );
                  goMealSelectFoodsPage(
                    CreateMealParams(
                      mealName: mealNameController.text,
                      menu: liveMenu,
                      controller: controller,
                    ),
                  );
                },
                child: const Text('Adicionar Refeição'),
              ),
            ],
          ),
        );
      },
    );
  }
}
