import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/entrepreneurship_service.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/business_card_widget.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/horizontal_cards_section.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/scrollable_filters.dart';
import 'package:frontend_mobile_app_flutter/core/constants/filter_constants.dart';

class TabContentEntrepreneurships extends StatefulWidget {
  const TabContentEntrepreneurships({super.key});

  @override
  _TabContentEntrepreneurshipsState createState() =>
      _TabContentEntrepreneurshipsState();
}

class _TabContentEntrepreneurshipsState
    extends State<TabContentEntrepreneurships> {
  String _selectedCategory = "Todos";
  final EntrepreneurshipService _service = EntrepreneurshipService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Entrepreneurship> _entrepreneurships = [];

  // Usar FilterConstants para las categorías
  final List<String> _categories = ["Todos", ...FilterConstants.categories];

  // Variables para filtros avanzados
  List<String> _advancedSelectedCategories = [];
  String _selectedModality = "Todos";
  String _selectedLocation = "Lima";

  @override
  void initState() {
    super.initState();
    _fetchEntrepreneurships();
  }

  Future<void> _fetchEntrepreneurships() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.getEntrepreneurships(page: 0, size: 50);

      setState(() {
        _entrepreneurships = response.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los emprendimientos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Entrepreneurship> _getFilteredEntrepreneurships() {
    List<Entrepreneurship> filtered = _entrepreneurships;

    // Filtrar por categoría básica (solo si no hay filtros avanzados activos)
    if (_selectedCategory != "Todos" && !_hasAdvancedFiltersActive()) {
      filtered = filtered
          .where((e) =>
              e.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Filtrar por categorías avanzadas
    if (_advancedSelectedCategories.isNotEmpty) {
      filtered = filtered
          .where((e) => _advancedSelectedCategories
              .any((cat) => e.category.toLowerCase() == cat.toLowerCase()))
          .toList();
    }

    // Filtrar por ubicación (solo si no es Lima)
    if (_selectedLocation != "Lima") {
      filtered = filtered.where((e) {
        return e.addresses.any((address) =>
            address.toLowerCase().contains(_selectedLocation.toLowerCase()));
      }).toList();
    }

    // Filtrar por modalidad si es necesario (aquí podrías agregar lógica específica)
    // Por ejemplo, si tienes un campo de modalidad en el modelo Entrepreneurship

    return filtered;
  }

  bool _hasAdvancedFiltersActive() {
    return _advancedSelectedCategories.isNotEmpty ||
        _selectedModality != "Todos" ||
        _selectedLocation != "Lima";
  }

  void _onAdvancedFiltersApplied(
      List<String> categories, String modality, String location) {
    setState(() {
      _advancedSelectedCategories = categories;
      _selectedModality = modality;
      _selectedLocation = location;

      // Limpiar filtro básico cuando se aplican filtros avanzados
      if (_hasAdvancedFiltersActive()) {
        _selectedCategory = "Todos";
      }
    });

    // Debug log
    print('🔍 Filtros aplicados:');
    print('  Categorías: $categories');
    print('  Modalidad: $modality');
    print('  Ubicación: $location');
    print(
        '  Resultados: ${_getFilteredEntrepreneurships().length}/${_entrepreneurships.length}');
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = "Todos";
      _advancedSelectedCategories = [];
      _selectedModality = "Todos";
      _selectedLocation = "Lima";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchEntrepreneurships,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_entrepreneurships.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No se encontraron emprendimientos"),
            Text("Intenta recargar la pantalla"),
          ],
        ),
      );
    }

    final filteredEntrepreneurships = _getFilteredEntrepreneurships();

    final recentEntrepreneurships =
        List<Entrepreneurship>.from(filteredEntrepreneurships)
          ..sort((a, b) => b.id.compareTo(a.id));

    final mostRecent = recentEntrepreneurships.take(5).toList();

    final withMostFiles = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => b.s3Files.length.compareTo(a.s3Files.length));

    final mostCollaborations = withMostFiles.take(5).toList();

    return Column(
      children: [
        ScrollableFilters(
          selectedCategory: _selectedCategory,
          onCategorySelected: (newCategory) {
            setState(() {
              _selectedCategory = newCategory;
              // Limpiar filtros avanzados cuando se selecciona una categoría básica
              if (newCategory != "Todos") {
                _advancedSelectedCategories = [];
                _selectedModality = "Todos";
                _selectedLocation = "Lima";
              }
            });
          },
          categories: _categories,
          onAdvancedFiltersApplied: _onAdvancedFiltersApplied,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchEntrepreneurships,
            child: ListView(
              padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (filteredEntrepreneurships.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Ups...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No encontramos resultados que coincidan con tus criterios de búsqueda. Prueba con otros.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _clearAllFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Limpiar filtros'),
                        ),
                      ],
                    ),
                  )
                else ...[
                  if (mostRecent.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title: "Más recientes (${mostRecent.length})",
                        cards: mostRecent
                            .map((e) => BusinessCardWidget(entrepreneurship: e))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (mostCollaborations.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title:
                            "Más colaboraciones (${mostCollaborations.length})",
                        cards: mostCollaborations
                            .map((e) => BusinessCardWidget(entrepreneurship: e))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (mostCollaborations.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title:
                            "Mejor valoración (${mostCollaborations.length})",
                        cards: mostCollaborations
                            .map((e) => BusinessCardWidget(entrepreneurship: e))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
