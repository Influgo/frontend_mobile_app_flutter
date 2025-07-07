import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/category_button.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/filter_button.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/filter_modal.dart';
import 'package:frontend_mobile_app_flutter/core/constants/filter_constants.dart';

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
  // Categorías sincronizadas con FilterModal usando FilterConstants
  final List<String> _defaultCategories = [
    "Todos",
    ...FilterConstants.categories
  ];

  // Estados para los filtros avanzados
  List<String> _selectedCategories = [];
  String _selectedModality = "Todos";
  String _selectedLocation = "Lima";

  // Función para verificar si hay filtros avanzados activos
  bool _hasAdvancedFiltersActive() {
    return _selectedCategories.isNotEmpty ||
        _selectedModality != "Todos" ||
        _selectedLocation != "Lima";
  }

  // Función para contar el número de filtros activos
  int _getActiveFiltersCount() {
    int count = 0;

    // Contar categorías seleccionadas
    count += _selectedCategories.length;

    // Contar modalidad si no es "Todos"
    if (_selectedModality != "Todos") {
      count += 1;
    }

    // Contar ubicación si no es "Lima" (valor por defecto)
    if (_selectedLocation != "Lima") {
      count += 1;
    }

    return count;
  }

  void _showFilterModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterModal(
          categories: widget.categories ?? FilterConstants.categories,
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
      _selectedCategories = [];
      _selectedModality = "Todos";
      _selectedLocation = "Lima";
    });

    // Notificar al padre que se limpiaron los filtros
    if (widget.onAdvancedFiltersApplied != null) {
      widget.onAdvancedFiltersApplied!([], "Todos", "Lima");
    }

    // También limpiar el filtro básico
    widget.onCategorySelected("Todos");
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categoriesToShow =
        widget.categories ?? _defaultCategories;
    final bool hasAdvancedFilters = _hasAdvancedFiltersActive();
    final int activeFiltersCount = _getActiveFiltersCount();

    return Container(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // FilterButton con estado visual y contador
            FilterButton(
              onPressed: () => _showFilterModal(context),
              isActive: hasAdvancedFilters,
              filterCount: activeFiltersCount, // ← NUEVO PARÁMETRO
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
