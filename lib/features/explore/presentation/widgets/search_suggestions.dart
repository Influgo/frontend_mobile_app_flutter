import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/entrepreneurship_service.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/recent_searches_service.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/pages/explora_detail_page.dart';

class SearchSuggestions extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSuggestionTap;

  const SearchSuggestions({
    super.key,
    required this.searchQuery,
    required this.onSuggestionTap,
  });

  @override
  _SearchSuggestionsState createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends State<SearchSuggestions> {
  final EntrepreneurshipService _service = EntrepreneurshipService();
  final RecentSearchesService _recentSearchesService = RecentSearchesService();

  List<RecentSearch> _recentSearches = [];
  List<RecentSearch> _filteredRecentSearches = [];
  List<Entrepreneurship> _suggestions = [];
  bool _isLoading = false;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void didUpdateWidget(SearchSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchQuery != _lastSearchQuery) {
      _lastSearchQuery = widget.searchQuery;

      if (widget.searchQuery.isEmpty) {
        setState(() {
          _filteredRecentSearches = _recentSearches;
          _suggestions.clear();
        });
        _loadRecentSearches();
      } else {
        _filterRecentSearches();
        _loadSuggestions();
      }
    }
  }

  Future<void> _loadRecentSearches() async {
    final recentSearches = await _recentSearchesService.getRecentSearches();
    setState(() {
      _recentSearches = recentSearches;
      _filteredRecentSearches = widget.searchQuery.isEmpty
          ? recentSearches
          : recentSearches
              .where((search) => search.name
                  .toLowerCase()
                  .contains(widget.searchQuery.toLowerCase()))
              .toList();
    });
  }

  void _filterRecentSearches() {
    setState(() {
      _filteredRecentSearches = _recentSearches
          .where((search) => search.name
              .toLowerCase()
              .contains(widget.searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadSuggestions() async {
    if (widget.searchQuery.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _service.searchEntrepreneurships(
        name: widget.searchQuery.trim(),
      );

      setState(() {
        _suggestions = response.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _suggestions.clear();
        _isLoading = false;
      });
      print('Error loading suggestions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estado inicial sin búsqueda
    if (widget.searchQuery.isEmpty) {
      return _recentSearches.isEmpty
          ? _buildEmptyState()
          : _buildRecentSearchesList();
    }

    // Estado con búsqueda activa - mostrar sugerencias
    return _buildSuggestionsView();
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

  Widget _buildRecentSearchesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredRecentSearches.length,
      itemBuilder: (context, index) {
        final recentSearch = _filteredRecentSearches[index];
        return _buildRecentSearchItem(recentSearch);
      },
    );
  }

  Widget _buildSuggestionsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Búsquedas recientes filtradas (si hay)
        if (_filteredRecentSearches.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Búsquedas recientes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey[700],
              ),
            ),
          ),
          ...List.generate(_filteredRecentSearches.length, (index) {
            final recentSearch = _filteredRecentSearches[index];
            return _buildRecentSearchItem(recentSearch);
          }),
          if (_suggestions.isNotEmpty) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[200],
            ),
          ],
        ],

        // Sugerencias del endpoint
        if (_suggestions.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Sugerencias',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final entrepreneurship = _suggestions[index];
                return _buildSuggestionItem(entrepreneurship);
              },
            ),
          ),
        ] else if (_isLoading) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Sugerencias',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ] else if (_filteredRecentSearches.isEmpty) ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off,
                      size: 30,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No se encontraron sugerencias',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentSearchItem(RecentSearch recentSearch) {
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: () async {
          // Si es de tipo entrepreneurship, navegar directamente
          if (recentSearch.type == 'entrepreneur') {
            // Buscar el entrepreneurship completo para navegar
            try {
              final response = await _service.searchEntrepreneurships(
                name: recentSearch.name,
              );
              final entrepreneurship = response.content.firstWhere(
                (e) => e.id.toString() == recentSearch.id,
                orElse: () => response.content.first,
              );

              // Actualizar en búsquedas recientes
              await _recentSearchesService.addRecentSearch(recentSearch);

              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExploraDetailPage(
                      entrepreneurship: entrepreneurship,
                    ),
                  ),
                );
              }
            } catch (e) {
              // Si no se encuentra, usar como sugerencia de búsqueda
              widget.onSuggestionTap(recentSearch.name);
            }
          } else {
            // Para influencers u otros tipos, usar como sugerencia de búsqueda
            widget.onSuggestionTap(recentSearch.name);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Ícono o avatar
              if (recentSearch.logoUrl != null &&
                  recentSearch.logoUrl!.isNotEmpty)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(recentSearch.logoUrl!),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
              const SizedBox(width: 12),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recentSearch.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recentSearch.nickname.isNotEmpty)
                      Text(
                        '@${recentSearch.nickname}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Botón eliminar
              GestureDetector(
                onTap: () async {
                  await _recentSearchesService.removeRecentSearch(
                    recentSearch.id,
                    recentSearch.type,
                  );
                  _loadRecentSearches();
                },
                child: Container(
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

  Widget _buildSuggestionItem(Entrepreneurship entrepreneurship) {
    return SizedBox(
      height: 50,
      child: InkWell(
        onTap: () async {
          // Guardar en búsquedas recientes
          final recentSearch =
              RecentSearchesService.fromEntrepreneurship(entrepreneurship);
          await _recentSearchesService.addRecentSearch(recentSearch);

          // Navegar a detalle
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExploraDetailPage(
                  entrepreneurship: entrepreneurship,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[200],
                backgroundImage: entrepreneurship.entrepreneurLogo?.url != null
                    ? NetworkImage(entrepreneurship.entrepreneurLogo!.url)
                    : null,
                child: entrepreneurship.entrepreneurLogo?.url == null
                    ? Icon(Icons.business, color: Colors.grey[500], size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entrepreneurship.entrepreneurshipName,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${entrepreneurship.entrepreneursNickname}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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
