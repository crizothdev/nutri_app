import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/food.dart';
import 'package:nutri_app/core/models/menu.dart';
import 'package:nutri_app/modules/food_menus/client_menus_controller.dart';
import 'package:nutri_app/modules/food_menus/menu_details_page.dart';
import 'package:nutri_app/routes.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class CreateMealParams {
  final String mealName;
  final Menu menu;
  final ClientMenusController controller;
  CreateMealParams({
    required this.mealName,
    required this.menu,
    required this.controller,
  });
}

class MealSelectFoodsPage extends StatefulWidget {
  CreateMealParams params;
  MealSelectFoodsPage({super.key, required this.params});

  @override
  State<MealSelectFoodsPage> createState() => _MealSelectFoodsPageState();
}

class _MealSelectFoodsPageState extends State<MealSelectFoodsPage> {
  ClientMenusController get controller => widget.params.controller;
  String get mealName => widget.params.mealName;
  Menu get menu => widget.params.menu;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.loadFoods();
  }

  Future<void> showCart() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.9, // 90% da tela; ajuste se quiser 100%
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: CartSheet(
              controller: controller,
              mealName: mealName,
              menu: menu,
            ),
          ),
        );
      },
    );
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
            'Selecionar alimentos para $mealName',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButton: AnimatedBuilder(
          animation: controller,
          builder: (_, __) => Badge(
            padding: const EdgeInsets.all(2),
            label: Text(
              '${controller.cart.length}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            child: FloatingActionButton(
              onPressed: showCart, // <<<<<<<<<<
              backgroundColor: const Color(0xFF4B6B36),
              child: const Icon(Icons.restaurant_outlined, color: Colors.white),
            ),
          ),
        ),
        builder: (context, state) {
          if (state.foods.isEmpty)
            return const Center(
              child: Text('Página de seleção de alimentos'),
            );

          return ListView.builder(
            itemCount: state.foods.length,
            itemBuilder: (context, index) {
              final food = state.foods[index];
              return ListTile(
                title: Text(food.name),
                subtitle: Row(
                  children: [
                    Text('${food.calories} kcal'),
                    SizedBox(width: 40),
                    Text('${food.defaultPortion}'),
                  ],
                ),
                trailing: const Icon(Icons.add),
                onTap: () {
                  controller.addFoodToCart(food);
                },
              );
            },
          );
        });
  }
}

class CartSheet extends StatelessWidget {
  final ClientMenusController controller;
  final String mealName;
  final Menu menu;
  const CartSheet({
    super.key,
    required this.controller,
    required this.mealName,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        if (controller.cart.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Carrinho vazio',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          );
        }

        return Column(
          children: [
            // "AppBar" do sheet
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Text('Carrinho',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: controller.cart.length,
                itemBuilder: (_, index) {
                  final item = controller.cart[index];
                  return ListTile(
                    title: Text(item.food.name),
                    subtitle: Row(
                      children: [
                        Text('${item.food.calories} kcal'),
                        SizedBox(width: 20),
                        Text(
                            '(${item.quantity.toInt()} x ${item.food.defaultPortion})'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => controller.removeFoodFromCart(item),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                  onPressed: () async {
                    final meal = Meal(
                        title: mealName,
                        // cópia defensiva da lista e dos itens
                        foods: [...controller.cart]);
                    final updated =
                        await controller.saveMeal(meal: meal, menu: menu);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if (menu.id != null) {
                      goMenuDetails(
                          MenuDetailsParams(
                            menu: updated,
                            controller: controller,
                          ),
                          replace: true);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Criar refeição'),
                    ],
                  )),
            ),
          ],
        );
      },
    );
  }
}
