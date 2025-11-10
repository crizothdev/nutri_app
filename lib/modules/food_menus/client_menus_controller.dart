import 'package:flutter/material.dart';
import 'package:nutri_app/app_initializer.dart';
import 'package:nutri_app/core/models/food.dart';
import 'package:nutri_app/core/models/menu.dart';
import 'package:nutri_app/modules/food_menus/menu_details_page.dart';
import 'package:nutri_app/routes.dart';

class ClientMenusController extends ChangeNotifier {
  bool _isLoading = false;
  List<Menu> _menus = [];
  List<Food> _foods = [];
  List<MealFood> cart = [];
  int? _selectedClientId;

  final menuRepo = AppInitializer.menusRepository;
  final foodRepo = AppInitializer.foodsRepository;

  List<Menu> get menus => _menus; // Placeholder for menus list
  List<Food> get foods => _foods;
  toggleLoading(bool? val) {
    _isLoading = val ?? !_isLoading;
    notifyListeners();
  }

  bool get isLoading => _isLoading == true;
  void addFoodToCart(Food food) {
    // procura se já existe esse alimento no carrinho
    final index = cart.indexWhere((mf) => mf.food.code == food.code);

    if (index == -1) {
      // não existe ainda → adiciona primeira unidade
      cart.add(MealFood(food: food, quantity: 1));
    } else {
      // já existe → cria nova instância com quantidade +1
      final existing = cart[index];
      final updated = existing.copyWith(quantity: existing.quantity + 1);
      cart[index] = updated;
    }

    notifyListeners();
  }

  void removeFoodFromCart(MealFood mealFood) {
    final index = cart.indexWhere((mf) => mf.food.code == mealFood.food.code);
    if (index == -1) return;

    final item = cart[index];

    if (item.quantity > 1) {
      final updated = item.copyWith(quantity: item.quantity - 1);
      cart[index] = updated;
    } else {
      cart.removeAt(index);
    }

    notifyListeners();
  }

  fetchMenus(int clientId) async {
    toggleLoading(true);

    _selectedClientId = clientId;
    try {
      menuRepo.byClient(clientId).then((value) {
        _menus = value;
        toggleLoading(false);
      });
    } catch (e) {
      toggleLoading(false);
    } finally {
      toggleLoading(false);
    }
  }

// no controller
  Future<Menu> saveMeal({
    required Meal meal,
    required Menu menu,
  }) async {
    toggleLoading(true);
    try {
      final mealWithClonedFoods = meal.copyWith(
        foods: meal.foods.map((mf) => mf.copyWith()).toList(),
      );

      final clientId = _selectedClientId;
      if (clientId == null) {
        return menu;
      }

      Menu currentMenu;

      if (menu.id == null) {
        // cria menu (auto-inc) + link com cliente
        final newMenuId = await menuRepo.create(
          title: menu.title ?? 'Novo cardápio',
          targetKcal: menu.targetKcal,
          clientId: clientId,
        );

        currentMenu = menu.copyWith(id: newMenuId, meals: [...menu.meals]);
        currentMenu.meals.add(mealWithClonedFoods);

        await menuRepo.update(currentMenu);

        // insere/atualiza na lista em memória
        _menus = [..._menus, currentMenu];
      } else {
        currentMenu = _menus.firstWhere((m) => m.id == menu.id);
        currentMenu.meals.add(mealWithClonedFoods);
        await menuRepo.update(currentMenu);

        final ix = _menus.indexWhere((m) => m.id == currentMenu.id);
        if (ix != -1) _menus[ix] = currentMenu;
      }

      cart.clear();
      notifyListeners();
      return currentMenu; // <<<<<< retorna o menu certo (com ID/meals)
    } finally {
      toggleLoading(false);
    }
  }

  createAndEditMenu(Menu menu, {bool isNew = false}) {
    // Lógica para criar e editar o cardápio
    goMenuDetails(
        MenuDetailsParams(menu: menu, controller: this, isNewMenu: isNew));
  }

  openOrEditMenu(Menu menu) {
    //  abrir e editar o cardápio
    goMenuDetails(MenuDetailsParams(menu: menu, controller: this));
  }

  loadFoods() {
    toggleLoading(true);
    try {
      foodRepo.getAll().then((value) {
        _foods = value;
        toggleLoading(false);
      });
    } catch (e) {
      toggleLoading(false);
    } finally {
      toggleLoading(false);
    }
  }

  deleteMenuFromUserOrFromBase(Menu menu) async {
    if (_selectedClientId == null) return;
    menuRepo.deleteMenuForClient(menu.id!, _selectedClientId!).then((value) {
      _menus.removeWhere((m) => m.id == menu.id);
      notifyListeners();
    });
  }

  deleteMeal({required Meal meal, required int menuId}) {
    final menu = _menus.firstWhere((m) => m.id == menuId);
    menu.meals.removeWhere((m) => m == meal);
    menuRepo.update(menu);
    notifyListeners();
  }
}
