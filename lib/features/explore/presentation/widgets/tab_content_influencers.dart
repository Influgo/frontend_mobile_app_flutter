import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/influencer_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/influencer_service.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/horizontal_cards_section.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/influencer_card_widget.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/scrollable_filters_influencer.dart';
import 'package:frontend_mobile_app_flutter/core/constants/filter_constants.dart';

class TabContentInfluencers extends StatefulWidget {
  const TabContentInfluencers({super.key});

  @override
  _TabContentInfluencersState createState() => _TabContentInfluencersState();
}

class _TabContentInfluencersState extends State<TabContentInfluencers>
    with AutomaticKeepAliveClientMixin<TabContentInfluencers> {
  
  // Filtros básicos y avanzados
  String _selectedCategory = "Todos";
  List<String> _advancedSelectedCategories = [];
  String _selectedLocation = "Todos";

  final InfluencerService _service = InfluencerService();

  // Estados de carga
  bool _isInitialLoading = true;
  bool _isLoadingMoreAll = false;
  String? _errorMessage;

  // Almacena todos los influencers originales y paginación
  List<Influencer> _allInfluencers = [];
  int _currentPageAll = 0;
  final int _pageSizeAll = 50;
  bool _hasMoreAll = true;

  // Categorías específicas para influencers
  List<String> _categories = ["Todos", ...FilterConstants.categories];

  // Listas pre-procesadas para la UI y contadores de ítems visibles
  List<Influencer> _mostPopularDisplay = [];
  int _visiblePopularCount = 5;
  
  List<Influencer> _mostRequestedDisplay = [];
  int _visibleRequestedCount = 5;
  
  List<Influencer> _bestRatedDisplay = [];
  int _visibleBestRatedCount = 5;

  // Listas completas para la vista cuadricular
  List<Influencer> _allPopularSorted = [];
  List<Influencer> _allRequestedSorted = [];
  List<Influencer> _allBestRatedSorted = [];

  final int _itemsToLoadMore = 5;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (_allInfluencers.isEmpty && !_isInitialLoading) {
      _fetchInfluencers(isInitialLoad: true);
    } else if (_allInfluencers.isEmpty) {
      _fetchInfluencers(isInitialLoad: true);
    }
  }

  Future<void> _fetchInfluencers({
    bool isInitialLoad = false, 
    bool loadMore = false
  }) async {
    if (loadMore && !_hasMoreAll) {
      if (mounted) setState(() => _isLoadingMoreAll = false);
      return;
    }

    if (loadMore && _isLoadingMoreAll) return;
    if (isInitialLoad && _isInitialLoading && _allInfluencers.isNotEmpty) return;

    setState(() {
      if (isInitialLoad) {
        _isInitialLoading = true;
        _allInfluencers = [];
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
      final response = await _service.getInfluencers(
        page: _currentPageAll,
        size: _pageSizeAll,
      );

      if (mounted) {
        setState(() {
          _allInfluencers.addAll(response.content);
          _hasMoreAll = response.content.length == _pageSizeAll;
          
          //_processAndPrepareDisplayData();
          
          //if (isInitialLoad) _isInitialLoading = false;
          //if (loadMore) _isLoadingMoreAll = false;

          if (isInitialLoad) {
            final uniqueCategories = _allInfluencers
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
          _errorMessage = 'Error al cargar los influencers: ${e.toString()}';
          if (isInitialLoad) _isInitialLoading = false;
          if (loadMore) _isLoadingMoreAll = false;
        });
      }
    }
  }

  void _resetVisibleCounts() {
    _visiblePopularCount = _itemsToLoadMore;
    _visibleRequestedCount = _itemsToLoadMore;
    _visibleBestRatedCount = _itemsToLoadMore;
  }

  List<Influencer> _getFilteredInfluencers() {
    List<Influencer> filtered = _allInfluencers;

    // Filtrar por categoría básica (solo si no hay filtros avanzados activos)
    if (_selectedCategory != "Todos" && !_hasAdvancedFiltersActive()) {
      filtered = filtered
          .where((e) => e.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Filtrar por categorías avanzadas
    if (_advancedSelectedCategories.isNotEmpty) {
      filtered = filtered
          .where((e) => _advancedSelectedCategories
              .any((cat) => e.category.toLowerCase() == cat.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  bool _hasAdvancedFiltersActive() {
    return _advancedSelectedCategories.isNotEmpty ||
        _selectedLocation != "Todos";
  }

  void _processAndPrepareDisplayData() {
    final filteredInfluencers = _getFilteredInfluencers();

    if (filteredInfluencers.isEmpty && _allInfluencers.isNotEmpty) {
      _mostPopularDisplay = [];
      _mostRequestedDisplay = [];
      _bestRatedDisplay = [];
      
      _allPopularSorted = [];
      _allRequestedSorted = [];
      _allBestRatedSorted = [];
      return;
    }

    // Preparar "Más populares" - ordenar por seguidores
    _allPopularSorted = List<Influencer>.from(filteredInfluencers)
      ..sort((a, b) => b.followersCount.compareTo(a.followersCount));
    _mostPopularDisplay = _allPopularSorted.take(_visiblePopularCount).toList();

    // Preparar "Más solicitados" - ordenar por colaboraciones
    _allRequestedSorted = List<Influencer>.from(filteredInfluencers)
      ..sort((a, b) => b.collaborationsCount.compareTo(a.collaborationsCount));
    _mostRequestedDisplay = _allRequestedSorted.take(_visibleRequestedCount).toList();

    // Preparar "Mejor valoración" - ordenar por rating
    _allBestRatedSorted = List<Influencer>.from(filteredInfluencers)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    _bestRatedDisplay = _allBestRatedSorted.take(_visibleBestRatedCount).toList();
  }

  void _onAdvancedFiltersApplied(
      List<String> categories, String location) {
    setState(() {
      _advancedSelectedCategories = categories;
      _selectedLocation = location;
      
      if (_hasAdvancedFiltersActive()) {
        _selectedCategory = "Todos";
      }
      _resetVisibleCounts();
      _processAndPrepareDisplayData();
    });
  }

  void _onCategorySelected(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
      
      if (newCategory != "Todos") {
        _advancedSelectedCategories = [];
        _selectedLocation = "Todos";
      }
      _resetVisibleCounts();
      _processAndPrepareDisplayData();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = "Todos";
      _advancedSelectedCategories = [];
      _selectedLocation = "Todos";
      _resetVisibleCounts();
      _processAndPrepareDisplayData();
    });
  }

  // Funciones para cargar más en cada sección
  void _loadMoreForPopular() {
    setState(() {
      _visiblePopularCount += _itemsToLoadMore;
    });
    _checkAndFetchMoreAllDataIfNeeded();
  }

  void _loadMoreForRequested() {
    setState(() {
      _visibleRequestedCount += _itemsToLoadMore;
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
    final filtered = _getFilteredInfluencers();

    final popularTempCheck = List<Influencer>.from(filtered)
      ..sort((a, b) => b.followersCount.compareTo(a.followersCount));
    if (popularTempCheck.length < _visiblePopularCount) needsMoreData = true;

    final requestedTempCheck = List<Influencer>.from(filtered)
      ..sort((a, b) => b.collaborationsCount.compareTo(a.collaborationsCount));
    if (requestedTempCheck.length < _visibleRequestedCount) needsMoreData = true;

    final ratedTempCheck = List<Influencer>.from(filtered)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    if (ratedTempCheck.length < _visibleBestRatedCount) needsMoreData = true;

    if (needsMoreData && _hasMoreAll && !_isLoadingMoreAll) {
      _fetchInfluencers(loadMore: true);
    } else {
      setState(() {
        _processAndPrepareDisplayData();
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchInfluencers(isInitialLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isInitialLoading && _allInfluencers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allInfluencers.isEmpty) {
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

    if (_allInfluencers.isEmpty && !_isInitialLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No se encontraron influencers"),
            Text("Intenta recargar la pantalla"),
          ],
        ),
      );
    }

    final filteredInfluencers = _getFilteredInfluencers();

    // Determinar si se puede cargar más para cada sección
    final sortedPopular = List<Influencer>.from(filteredInfluencers)
      ..sort((a, b) => b.followersCount.compareTo(a.followersCount));
    bool canLoadMorePopular = _mostPopularDisplay.length < sortedPopular.length ||
        (_hasMoreAll && _mostPopularDisplay.length == sortedPopular.length);

    final sortedRequested = List<Influencer>.from(filteredInfluencers)
      ..sort((a, b) => b.collaborationsCount.compareTo(a.collaborationsCount));
    bool canLoadMoreRequested = _mostRequestedDisplay.length < sortedRequested.length ||
        (_hasMoreAll && _mostRequestedDisplay.length == sortedRequested.length);

    final sortedRated = List<Influencer>.from(filteredInfluencers)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    bool canLoadMoreRated = _bestRatedDisplay.length < sortedRated.length ||
        (_hasMoreAll && _bestRatedDisplay.length == sortedRated.length);

    return Column(
      children: [
        ScrollableFiltersInfluencer(
          selectedCategory: _selectedCategory,
          onCategorySelected: _onCategorySelected,
          categories: _categories,
          onAdvancedFiltersApplied: _onAdvancedFiltersApplied,
          selectedCategories: _advancedSelectedCategories,
          selectedLocation: _selectedLocation,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              padding: const EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 70),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (filteredInfluencers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
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
                          'No encontramos influencers que coincidan con tus criterios de búsqueda. Prueba con otros.',
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
                  if (_mostPopularDisplay.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title: "Más populares",
                        cards: _mostPopularDisplay
                            .map((e) => InfluencerCardWidget(influencer: e))
                            .toList(),
                        onLoadMore: canLoadMorePopular ? _loadMoreForPopular : null,
                        isLoadingMore: _isLoadingMoreAll &&
                            (_visiblePopularCount > _mostPopularDisplay.length),
                        hasMore: canLoadMorePopular,
                        allInfluencers: _allPopularSorted,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_mostRequestedDisplay.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title: "Más solicitados",
                        cards: _mostRequestedDisplay
                            .map((e) => InfluencerCardWidget(influencer: e))
                            .toList(),
                        onLoadMore: canLoadMoreRequested ? _loadMoreForRequested : null,
                        isLoadingMore: _isLoadingMoreAll &&
                            (_visibleRequestedCount > _mostRequestedDisplay.length),
                        hasMore: canLoadMoreRequested,
                        allInfluencers: _allRequestedSorted,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_bestRatedDisplay.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.topLeft,
                      child: HorizontalCardsSection(
                        title: "Mejor valoración",
                        cards: _bestRatedDisplay
                            .map((e) => InfluencerCardWidget(influencer: e))
                            .toList(),
                        onLoadMore: canLoadMoreRated ? _loadMoreForBestRated : null,
                        isLoadingMore: _isLoadingMoreAll &&
                            (_visibleBestRatedCount > _bestRatedDisplay.length),
                        hasMore: canLoadMoreRated,
                        allInfluencers: _allBestRatedSorted,
                      ),
                    ),
                  ],
                ],
                
                if (_isLoadingMoreAll && _allInfluencers.isNotEmpty)
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
