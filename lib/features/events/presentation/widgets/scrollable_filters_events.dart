import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/category_button.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/filter_button.dart';
import 'package:frontend_mobile_app_flutter/features/events/presentation/widgets/filter_modal_events.dart';
import 'package:frontend_mobile_app_flutter/core/constants/filter_constants.dart';

class ScrollableFiltersEvents extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<String>? categories;
  final Function(List<String>, String, String)? onAdvancedFiltersApplied;
  final List<String> selectedCategories;
  final String selectedLocation;
  final String selectedEventType;

  const ScrollableFiltersEvents({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.categories,
    this.onAdvancedFiltersApplied,
    this.selectedCategories = const [],
    this.selectedLocation = "Todos",
    this.selectedEventType = "Todos",
  });

  @override
  _ScrollableFiltersEventsState createState() => _ScrollableFiltersEventsState();
}

class _ScrollableFiltersEventsState extends State<ScrollableFiltersEvents> {
  // Categorías sincronizadas con FilterModal usando FilterConstants
  final List<String> _defaultCategories = [
    "Todos",
    ...FilterConstants.categories
  ];

  // Estados para los filtros avanzados - sincronizados con el padre
  late List<String> _selectedCategories;
  late String _selectedLocation;
  late String _selectedEventType;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedLocation = widget.selectedLocation;
    _selectedEventType = widget.selectedEventType;
  }

  @override
  void didUpdateWidget(ScrollableFiltersEvents oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincronizar cuando cambien los valores del padre
    if (oldWidget.selectedCategories != widget.selectedCategories ||
        oldWidget.selectedLocation != widget.selectedLocation ||
        oldWidget.selectedEventType != widget.selectedEventType) {
      setState(() {
        _selectedCategories = List.from(widget.selectedCategories);
        _selectedLocation = widget.selectedLocation;
        _selectedEventType = widget.selectedEventType;
      });
    }
  }

  // Función para verificar si hay filtros avanzados activos
  bool _hasAdvancedFiltersActive() {
    return _selectedCategories.isNotEmpty ||
        _selectedLocation != "Todos" ||
        _selectedEventType != "Todos";
  }

  // Función para contar el número de filtros activos
  int _getActiveFiltersCount() {
    int count = 0;

    // Contar categorías seleccionadas
    count += _selectedCategories.length;

    // Contar ubicación si no es "Todos"
    if (_selectedLocation != "Todos") {
      count += 1;
    }

    // Contar tipo de evento si no es "Todos"
    if (_selectedEventType != "Todos") {
      count += 1;
    }

    return count;
  }

  void _showFilterModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterModalEvents(
          categories: widget.categories ?? FilterConstants.categories,
          selectedCategories: _selectedCategories,
          selectedLocation: _selectedLocation,
          selectedEventType: _selectedEventType,
          onApplyFilter: (categories, location, eventType) {
            setState(() {
              _selectedCategories = categories;
              _selectedLocation = location;
              _selectedEventType = eventType;
            });

            // Llamar al callback del padre
            if (widget.onAdvancedFiltersApplied != null) {
              widget.onAdvancedFiltersApplied!(categories, location, eventType);
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
      _selectedLocation = "Todos";
      _selectedEventType = "Todos";
    });

    // Notificar al padre que se limpiaron los filtros
    if (widget.onAdvancedFiltersApplied != null) {
      widget.onAdvancedFiltersApplied!([], "Todos", "Todos");
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // FilterButton con estado visual y contador
            FilterButton(
              onPressed: () => _showFilterModal(context),
              isActive: hasAdvancedFilters,
              filterCount: activeFiltersCount,
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