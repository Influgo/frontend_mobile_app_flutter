import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/entrepreneurship_service.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/recent_searches_service.dart';

class SearchContentEntrepreneurships extends StatefulWidget {
  final String searchQuery;

  const SearchContentEntrepreneurships({
    super.key,
    required this.searchQuery,
  });

  @override
  _SearchContentEntrepreneurshipsState createState() =>
      _SearchContentEntrepreneurshipsState();
}

class _SearchContentEntrepreneurshipsState
    extends State<SearchContentEntrepreneurships> {
  final EntrepreneurshipService _service = EntrepreneurshipService();
  final RecentSearchesService _recentSearchesService = RecentSearchesService();
  List<Entrepreneurship> _searchResults = [];
  List<RecentSearch> _recentSearches = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // Cargar búsquedas recientes
  Future<void> _loadRecentSearches() async {
    final recentSearches = await _recentSearchesService.getRecentSearches();
    setState(() {
      _recentSearches =
          recentSearches.where((s) => s.type == 'entrepreneur').toList();
    });
  }

  @override
  void didUpdateWidget(SearchContentEntrepreneurships oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Solo buscar si el query cambió y no está vacío
    if (widget.searchQuery != _lastSearchQuery) {
      _lastSearchQuery = widget.searchQuery;
      if (widget.searchQuery.isEmpty) {
        setState(() {
          _searchResults.clear();
          _errorMessage = null;
        });
        _loadRecentSearches(); // Recargar búsquedas recientes
      } else {
        _performSearch();
      }
    }
  }

  Future<void> _performSearch() async {
    if (widget.searchQuery.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usar el método de búsqueda
      final response = await _service.searchEntrepreneurships(
        name: widget.searchQuery.trim(),
      );

      setState(() {
        _searchResults = response.content;
        _isLoading = false;
      });

      print(
          '🔍 Búsqueda: "${widget.searchQuery}" - ${response.content.length} resultados');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en la búsqueda: ${e.toString()}';
        _isLoading = false;
        _searchResults.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar estado vacío o búsquedas recientes cuando no hay query
    if (widget.searchQuery.isEmpty) {
      return _recentSearches.isEmpty
          ? _buildEmptyState()
          : _buildRecentSearchesState();
    }

    // Mostrar loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mostrar error
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Mostrar resultados o estado de "sin resultados"
    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildResultsList();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay búsquedas recientes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchesState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        final recentSearch = _recentSearches[index];
        return _buildRecentSearchItem(recentSearch);
      },
    );
  }

  Widget _buildRecentSearchItem(RecentSearch recentSearch) {
    return Container(
      height: 31,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Reutilizar la búsqueda reciente (moverla al inicio)
          _recentSearchesService.addRecentSearch(recentSearch);
          _loadRecentSearches();
          print('Tap en búsqueda reciente: ${recentSearch.name}');
          // Aquí podrías navegar a la página de detalle
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              // Ícono de búsqueda reciente
              Icon(
                Icons.history,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 12),
              // Contenido expandido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recentSearch.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Botón de eliminar
              GestureDetector(
                onTap: () async {
                  await _recentSearchesService.removeRecentSearch(
                    recentSearch.id,
                    recentSearch.type,
                  );
                  _loadRecentSearches(); // Recargar la lista
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros términos de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 2),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final entrepreneurship = _searchResults[index];
        return _buildSearchResultItem(entrepreneurship);
      },
    );
  }

  Widget _buildSearchResultItem(Entrepreneurship entrepreneurship) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 1),
      child: InkWell(
        onTap: () async {
          // Guardar en búsquedas recientes
          final recentSearch =
              RecentSearchesService.fromEntrepreneurship(entrepreneurship);
          await _recentSearchesService.addRecentSearch(recentSearch);

          print('Tap en: ${entrepreneurship.entrepreneurshipName}');
          // Aquí puedes navegar a la página de detalle del emprendimiento
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
          child: Row(
            children: [
              // Avatar más pequeño
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[200],
                backgroundImage: entrepreneurship.entrepreneurLogo?.url != null
                    ? NetworkImage(entrepreneurship.entrepreneurLogo!.url)
                    : null,
                child: entrepreneurship.entrepreneurLogo?.url == null
                    ? Icon(Icons.business, color: Colors.grey[500], size: 12)
                    : null,
              ),
              const SizedBox(width: 12),
              // Contenido expandido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entrepreneurship.entrepreneurshipName,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${entrepreneurship.entrepreneursNickname}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
