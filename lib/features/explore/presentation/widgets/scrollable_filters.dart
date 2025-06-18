import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/category_button.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/filter_button.dart';

class ScrollableFilters extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<String>? categories;

  const ScrollableFilters({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.categories,
  });

  @override
  _ScrollableFiltersState createState() => _ScrollableFiltersState();
}

class _ScrollableFiltersState extends State<ScrollableFilters> {
  // Default categories if none are provided
  final List<String> _defaultCategories = [
    "Todos",
    "Moda y Belleza",
    "Viajes",
    "Arte",
    "Fitness",
    "Cultura",
    "Tecnología",
    "Gastronomía",
    "Deportes",
    "Negocios",
    "Cine",
    "Música"
  ];

  @override
  Widget build(BuildContext context) {
    // Use provided categories or default ones
    final List<String> categoriesToShow =
        widget.categories ?? _defaultCategories;

    return Container(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            FilterButton(
              onPressed: () {
                // Acción cuando se presiona el botón de filtro
              },
            ),
            ...List.generate(categoriesToShow.length, (index) {
              return CategoryButton(
                text: categoriesToShow[index],
                isActive: categoriesToShow[index] == widget.selectedCategory,
                isLast: index == categoriesToShow.length - 1,
                onPressed: () {
                  widget.onCategorySelected(categoriesToShow[index]);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
