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
    extends State<TabContentEntrepreneurships>
    with AutomaticKeepAliveClientMixin<TabContentEntrepreneurships> {
  // Filtros básicos y avanzados
  String _selectedCategory = "Todos";
  List<String> _advancedSelectedCategories = [];
  String _selectedModality = "Todos";
  String _selectedLocation = "Lima";

  final EntrepreneurshipService _service = EntrepreneurshipService();

  // Estados de carga
  bool _isInitialLoading = true;
  bool _isLoadingMoreAll = false;
  String? _errorMessage;

  // Almacena todos los emprendimientos originales y paginación
  List<Entrepreneurship> _allEntrepreneurships = [];
  int _currentPageAll = 0;
  final int _pageSizeAll = 50; // Mantenemos el tamaño original
  bool _hasMoreAll = true;

  // Usar FilterConstants para las categorías
  List<String> _categories = ["Todos", ...FilterConstants.categories];

  // Listas pre-procesadas para la UI y contadores de ítems visibles
  List<Entrepreneurship> _mostRecentDisplay = [];
  int _visibleRecentCount = 5;

  List<Entrepreneurship> _mostCollaborationsDisplay = [];
  int _visibleCollaborationsCount = 5;

  List<Entrepreneurship> _bestRatedDisplay = [];
  int _visibleBestRatedCount = 5;

  final int _itemsToLoadMore = 5;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (_allEntrepreneurships.isEmpty && !_isInitialLoading) {
      _fetchEntrepreneurships(isInitialLoad: true);
    } else if (_allEntrepreneurships.isEmpty) {
      _fetchEntrepreneurships(isInitialLoad: true);
    }
  }

  Future<void> _fetchEntrepreneurships(
      {bool isInitialLoad = false, bool loadMore = false}) async {
    if (loadMore && !_hasMoreAll) {
      if (mounted) setState(() => _isLoadingMoreAll = false);
      return;
    }
    if (loadMore && _isLoadingMoreAll) return;
    if (isInitialLoad && _isInitialLoading && _allEntrepreneurships.isNotEmpty)
      return;

    setState(() {
      if (isInitialLoad) {
        _isInitialLoading = true;
        _allEntrepreneurships = [];
        _currentPageAll = 0;
        _hasMoreAll = true;
        _resetVisibleCounts();
      }
      if (loadMore) {
        _isLoadingMoreAll = true;
        _currentPageAll++;
      }
      _errorMessage = null;
    });

    try {
      final response = await _service.getEntrepreneurships(
        page: _currentPageAll,
        size: _pageSizeAll,
      );

      if (mounted) {
        setState(() {
          _allEntrepreneurships.addAll(response.content);
          _hasMoreAll = response.content.length == _pageSizeAll;

          if (isInitialLoad) {
            // Actualizar categorías con datos reales además de FilterConstants
            final uniqueCategories = _allEntrepreneurships
                .map((e) => e.category)
                .where((category) =>
                    category != 'N/A' &&
                    category.isNotEmpty &&
                    !FilterConstants.categories.contains(category))
                .toSet()
                .toList();
            uniqueCategories.sort();
            _categories = [
              "Todos",
              ...FilterConstants.categories,
              ...uniqueCategories
            ];
          }

          _processAndPrepareDisplayData();

          if (isInitialLoad) _isInitialLoading = false;
          if (loadMore) _isLoadingMoreAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Error al cargar los emprendimientos: ${e.toString()}';
          if (isInitialLoad) _isInitialLoading = false;
          if (loadMore) _isLoadingMoreAll = false;
        });
      }
    }
  }

  void _resetVisibleCounts() {
    _visibleRecentCount = _itemsToLoadMore;
    _visibleCollaborationsCount = _itemsToLoadMore;
    _visibleBestRatedCount = _itemsToLoadMore;
  }

  List<Entrepreneurship> _getFilteredEntrepreneurships() {
    List<Entrepreneurship> filtered = _allEntrepreneurships;

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

    // Filtrar por modalidad si es necesario
    // Aquí podrías agregar lógica específica para modalidad

    return filtered;
  }

  bool _hasAdvancedFiltersActive() {
    return _advancedSelectedCategories.isNotEmpty ||
        _selectedModality != "Todos" ||
        _selectedLocation != "Lima";
  }

  void _processAndPrepareDisplayData() {
    final filteredEntrepreneurships = _getFilteredEntrepreneurships();

    if (filteredEntrepreneurships.isEmpty && _allEntrepreneurships.isNotEmpty) {
      _mostRecentDisplay = [];
      _mostCollaborationsDisplay = [];
      _bestRatedDisplay = [];
      return;
    }

    // Preparar "Más recientes"
    final recentTemp = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => b.id.compareTo(a.id));
    _mostRecentDisplay = recentTemp.take(_visibleRecentCount).toList();

    // Preparar "Más colaboraciones"
    final collaborationsTemp =
        List<Entrepreneurship>.from(filteredEntrepreneurships)
          ..sort((a, b) => b.s3Files.length.compareTo(a.s3Files.length));
    _mostCollaborationsDisplay =
        collaborationsTemp.take(_visibleCollaborationsCount).toList();

    // Preparar "Mejor valoración" (Placeholder)
    final ratedTemp = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => a.id.compareTo(b.id));
    _bestRatedDisplay = ratedTemp.take(_visibleBestRatedCount).toList();
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

      _resetVisibleCounts();
      _processAndPrepareDisplayData();
    });

    // Debug log
    print('🔍 Filtros aplicados:');
    print('  Categorías: $categories');
    print('  Modalidad: $modality');
    print('  Ubicación: $location');
    print(
        '  Resultados: ${_getFilteredEntrepreneurships().length}/${_allEntrepreneurships.length}');
  }

  void _onCategorySelected(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
      // Limpiar filtros avanzados cuando se selecciona una categoría básica
      if (newCategory != "Todos") {
        _advancedSelectedCategories = [];
        _selectedModality = "Todos";
        _selectedLocation = "Lima";
      }
      _resetVisibleCounts();
      _processAndPrepareDisplayData();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = "Todos";
      _advancedSelectedCategories = [];
      _selectedModality = "Todos";
      _selectedLocation = "Lima";
      _resetVisibleCounts();
      _processAndPrepareDisplayData();
    });
  }

  // Funciones para cargar más en cada sección
  void _loadMoreForRecent() {
    setState(() {
      _visibleRecentCount += _itemsToLoadMore;
    });
    _checkAndFetchMoreAllDataIfNeeded();
  }

  void _loadMoreForCollaborations() {
    setState(() {
      _visibleCollaborationsCount += _itemsToLoadMore;
    });
    _checkAndFetchMoreAllDataIfNeeded();
  }

  void _loadMoreForBestRated() {
    setState(() {
      _visibleBestRatedCount += _itemsToLoadMore;
    });
    _checkAndFetchMoreAllDataIfNeeded();
  }

  void _checkAndFetchMoreAllDataIfNeeded() {
    bool needsMoreData = false;
    final filtered = _getFilteredEntrepreneurships();

    final recentTempCheck = List<Entrepreneurship>.from(filtered)
      ..sort((a, b) => b.id.compareTo(a.id));
    if (recentTempCheck.length < _visibleRecentCount) needsMoreData = true;

    final collabTempCheck = List<Entrepreneurship>.from(filtered)
      ..sort((a, b) => b.s3Files.length.compareTo(a.s3Files.length));
    if (collabTempCheck.length < _visibleCollaborationsCount)
      needsMoreData = true;

    final ratedTempCheck = List<Entrepreneurship>.from(filtered)
      ..sort((a, b) => a.id.compareTo(b.id));
    if (ratedTempCheck.length < _visibleBestRatedCount) needsMoreData = true;

    if (needsMoreData && _hasMoreAll && !_isLoadingMoreAll) {
      _fetchEntrepreneurships(loadMore: true);
    } else {
      setState(() {
        _processAndPrepareDisplayData();
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchEntrepreneurships(isInitialLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isInitialLoading && _allEntrepreneurships.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allEntrepreneurships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_allEntrepreneurships.isEmpty && !_isInitialLoading) {
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

    // Determinar si se puede cargar más para cada sección
    final sortedRecent = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => b.id.compareTo(a.id));
    bool canLoadMoreRecent = _mostRecentDisplay.length < sortedRecent.length ||
        (_hasMoreAll && _mostRecentDisplay.length == sortedRecent.length);

    final sortedCollab = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => b.s3Files.length.compareTo(a.s3Files.length));
    bool canLoadMoreCollab =
        _mostCollaborationsDisplay.length < sortedCollab.length ||
            (_hasMoreAll &&
                _mostCollaborationsDisplay.length == sortedCollab.length);

    final sortedRated = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => a.id.compareTo(b.id));
    bool canLoadMoreRated = _bestRatedDisplay.length < sortedRated.length ||
        (_hasMoreAll && _bestRatedDisplay.length == sortedRated.length);

    return Column(
      children: [
        ScrollableFilters(
          selectedCategory: _selectedCategory,
          onCategorySelected: _onCategorySelected,
          categories: _categories,
          onAdvancedFiltersApplied: _onAdvancedFiltersApplied,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              padding:
                  const EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 70),
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
                  if (_mostRecentDisplay.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title: "Más recientes (${_mostRecentDisplay.length})",
                        cards: _mostRecentDisplay
                            .map((e) => BusinessCardWidget(entrepreneurship: e))
                            .toList(),
                        onLoadMore:
                            canLoadMoreRecent ? _loadMoreForRecent : null,
                        isLoadingMore: _isLoadingMoreAll &&
                            (_visibleRecentCount > _mostRecentDisplay.length),
                        hasMore: canLoadMoreRecent,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_mostCollaborationsDisplay.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title:
                            "Más colaboraciones (${_mostCollaborationsDisplay.length})",
                        cards: _mostCollaborationsDisplay
                            .map((e) => BusinessCardWidget(entrepreneurship: e))
                            .toList(),
                        onLoadMore: canLoadMoreCollab
                            ? _loadMoreForCollaborations
                            : null,
                        isLoadingMore: _isLoadingMoreAll &&
                            (_visibleCollaborationsCount >
                                _mostCollaborationsDisplay.length),
                        hasMore: canLoadMoreCollab,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_bestRatedDisplay.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title: "Mejor valoración (${_bestRatedDisplay.length})",
                        cards: _bestRatedDisplay
                            .map((e) => BusinessCardWidget(entrepreneurship: e))
                            .toList(),
                        onLoadMore:
                            canLoadMoreRated ? _loadMoreForBestRated : null,
                        isLoadingMore: _isLoadingMoreAll &&
                            (_visibleBestRatedCount > _bestRatedDisplay.length),
                        hasMore: canLoadMoreRated,
                      ),
                    ),
                  ],
                ],

                // Indicador de carga general al final si aplica
                if (_isLoadingMoreAll && _allEntrepreneurships.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
