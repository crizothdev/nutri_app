import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/meal.dart';
import 'package:nutri_app/core/models/meal_food.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final List<MealFood> foods;

  const MealCard({super.key, required this.meal, required this.foods});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E4D3A),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${foods.fold<double>(0, (sum, item) => sum + item.kcalTotal).toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE74C3C), 
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.add_circle,
                        size: 20, color: Color(0xFF4C7C3D)), 
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
              children: foods.map((food) {
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
                          '${food.notes ?? ''} (${food.quantity.toStringAsFixed(0)}g)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
