import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/entrepreneurship_service.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/business_card_widget.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/horizontal_cards_section.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/scrollable_filters.dart';

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
  List<String> _categories = ["Todos"];

  // Variables para filtros avanzados
  List<String> _advancedSelectedCategories = ["Todos"];
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

      final uniqueCategories = response.content
          .map((e) => e.category)
          .where((category) => category != 'N/A' && category.isNotEmpty)
          .toSet()
          .toList();

      uniqueCategories.sort();
      uniqueCategories.insert(0, "Todos");

      setState(() {
        _entrepreneurships = response.content;
        _categories = uniqueCategories;
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

    // Filtrar por categoría básica
    if (_selectedCategory != "Todos") {
      filtered = filtered
          .where((e) =>
              e.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Filtrar por categorías avanzadas
    if (!_advancedSelectedCategories.contains("Todos") &&
        _advancedSelectedCategories.isNotEmpty) {
      filtered = filtered
          .where((e) => _advancedSelectedCategories
              .any((cat) => e.category.toLowerCase() == cat.toLowerCase()))
          .toList();
    }

    // Filtrar por ubicación
    if (_selectedLocation != "Lima") {
      filtered = filtered.where((e) {
        return e.addresses.any((address) =>
            address.toLowerCase().contains(_selectedLocation.toLowerCase()));
      }).toList();
    }

    return filtered;
  }

  void _onAdvancedFiltersApplied(
      List<String> categories, String modality, String location) {
    setState(() {
      _advancedSelectedCategories = categories;
      _selectedModality = modality;
      _selectedLocation = location;

      // ← LIMPIAR FILTRO BÁSICO CUANDO SE APLICAN FILTROS AVANZADOS
      if (!categories.contains("Todos") || location != "Lima") {
        _selectedCategory = "Todos";
      }
    });

    // Debug log
    print('🔍 Filtros aplicados:');
    print('  Categorías: $categories');
    print('  Ubicación: $location');
    print(
        '  Resultados: ${_getFilteredEntrepreneurships().length}/${_entrepreneurships.length}');
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
              // ← LIMPIAR FILTROS AVANZADOS CUANDO SE SELECCIONA UNA CATEGORÍA BÁSICA
              if (newCategory != "Todos") {
                _advancedSelectedCategories = ["Todos"];
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
                // ← COMENTADO: Indicador de filtros activos
                /*
                if (_hasActiveFilters())
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtros aplicados: ${_getActiveFiltersText()}',
                            style: TextStyle(color: Colors.blue[600], fontSize: 12),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _advancedSelectedCategories = ["Todos"];
                              _selectedModality = "Todos";
                              _selectedLocation = "Lima";
                              _selectedCategory = "Todos";
                            });
                          },
                          child: Icon(Icons.close, color: Colors.blue[600], size: 20),
                        ),
                      ],
                    ),
                  ),
                */

                if (filteredEntrepreneurships.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron emprendimientos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta ajustar los filtros o buscar en otras categorías',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total disponible: ${_entrepreneurships.length} emprendimientos',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
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

  // ← COMENTADO: Helpers para filtros activos
  /*
  bool _hasActiveFilters() {
    return !_advancedSelectedCategories.contains("Todos") || 
           _selectedModality != "Todos" || 
           _selectedLocation != "Lima" ||
           _selectedCategory != "Todos";
  }

  String _getActiveFiltersText() {
    List<String> activeFilters = [];
    
    if (_selectedCategory != "Todos") {
      activeFilters.add("Categoría: $_selectedCategory");
    }
    
    if (!_advancedSelectedCategories.contains("Todos")) {
      activeFilters.add("Categorías: ${_advancedSelectedCategories.join(', ')}");
    }
    
    if (_selectedModality != "Todos") {
      activeFilters.add("Modalidad: $_selectedModality");
    }
    
    if (_selectedLocation != "Lima") {
      activeFilters.add("Ubicación: $_selectedLocation");
    }
    
    return activeFilters.join(" | ");
  }
  */
}
