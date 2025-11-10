import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/menu.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const MealCard({
    super.key,
    required this.meal,
    required this.onDelete,
    required this.onEdit,
  });

  Future<void> showFloatingMenu(BuildContext context, Offset globalPos) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(globalPos.dx, globalPos.dy, 0, 0),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      items: const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Editar')
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18),
              SizedBox(width: 8),
              Text('Excluir')
            ],
          ),
        ),
      ],
    );

    if (selected == 'edit') onEdit();
    if (selected == 'delete') onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        showFloatingMenu(context, details.globalPosition);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8BA77F), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        meal.title ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E4D3A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${meal.foods.fold<double>(0, (sum, item) => sum + item.totalCalories).toStringAsFixed(0)} kcal)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(color: Color(0xFFDDE3D3), thickness: 1),
              const SizedBox(height: 6),
              // Alimentos
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: meal.foods.map((food) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: Icon(Icons.circle,
                              size: 6, color: Color(0xFF4C7C3D)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${food.food.name ?? ''} (${food.quantity.toStringAsFixed(0)} x ${food.food.defaultPortion ?? ''})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        food.totalCalories != null
                            ? Text(
                                '${food.totalCalories!.toStringAsFixed(0)} kcal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE74C3C),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
