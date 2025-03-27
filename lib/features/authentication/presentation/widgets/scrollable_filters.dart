import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/category_button.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/filter_button.dart';

class ScrollableFilters extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const ScrollableFilters({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _ScrollableFiltersState createState() => _ScrollableFiltersState();
}

class _ScrollableFiltersState extends State<ScrollableFilters> {
  List<String> categorias = [
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
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
            ...List.generate(categorias.length, (index) {
              return CategoryButton(
                text: categorias[index],
                isActive: categorias[index] == widget.selectedCategory,
                isLast: index == categorias.length - 1,
                onPressed: () {
                  widget.onCategorySelected(categorias[index]);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
