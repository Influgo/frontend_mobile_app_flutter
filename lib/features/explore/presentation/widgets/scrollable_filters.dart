import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/category_button.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/filter_button.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/filter_modal.dart';

class ScrollableFilters extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<String>? categories;
  final Function(List<String>, String, String)? onAdvancedFiltersApplied;

  const ScrollableFilters({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.categories,
    this.onAdvancedFiltersApplied,
  });

  @override
  _ScrollableFiltersState createState() => _ScrollableFiltersState();
}

class _ScrollableFiltersState extends State<ScrollableFilters> {
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

  // Estados para los filtros avanzados
  List<String> _selectedCategories = ["Todos"];
  String _selectedModality = "Todos";
  String _selectedLocation = "Lima";

  // Función para verificar si hay filtros avanzados activos
  bool _hasAdvancedFiltersActive() {
    return !_selectedCategories.contains("Todos") ||
        _selectedModality != "Todos" ||
        _selectedLocation != "Lima";
  }

  // ← CAMBIO: Usar Navigator.push en lugar de showModalBottomSheet
  void _showFilterModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterModal(
          categories: widget.categories ?? _defaultCategories,
          selectedCategories: _selectedCategories,
          selectedModality: _selectedModality,
          selectedLocation: _selectedLocation,
          onApplyFilter: (categories, modality, location) {
            setState(() {
              _selectedCategories = categories;
              _selectedModality = modality;
              _selectedLocation = location;
            });

            // Llamar al callback del padre
            if (widget.onAdvancedFiltersApplied != null) {
              widget.onAdvancedFiltersApplied!(categories, modality, location);
            }
          },
        ),
      ),
    );
  }

  // Función para limpiar todos los filtros
  void _clearAllFilters() {
    setState(() {
      _selectedCategories = ["Todos"];
      _selectedModality = "Todos";
      _selectedLocation = "Lima";
    });

    // Notificar al padre que se limpiaron los filtros
    if (widget.onAdvancedFiltersApplied != null) {
      widget.onAdvancedFiltersApplied!(["Todos"], "Todos", "Lima");
    }

    // También limpiar el filtro básico
    widget.onCategorySelected("Todos");
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categoriesToShow =
        widget.categories ?? _defaultCategories;
    final bool hasAdvancedFilters = _hasAdvancedFiltersActive();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // FilterButton con estado visual
            FilterButton(
              onPressed: () => _showFilterModal(context),
              isActive: hasAdvancedFilters,
            ),
            ...List.generate(categoriesToShow.length, (index) {
              final categoryName = categoriesToShow[index];
              final bool isCategoryActive;

              // Lógica visual: Si hay filtros avanzados, solo "Todos" puede estar activo
              if (hasAdvancedFilters) {
                isCategoryActive =
                    false; // Todas las categorías en blanco cuando hay filtros avanzados
              } else {
                isCategoryActive = categoryName == widget.selectedCategory;
              }

              return CategoryButton(
                text: categoryName,
                isActive: isCategoryActive,
                isLast: index == categoriesToShow.length - 1,
                onPressed: () {
                  // Si se presiona "Todos", limpiar todos los filtros
                  if (categoryName == "Todos") {
                    _clearAllFilters();
                  } else {
                    // Solo permitir selección si no hay filtros avanzados activos
                    if (!hasAdvancedFilters) {
                      widget.onCategorySelected(categoryName);
                    }
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
