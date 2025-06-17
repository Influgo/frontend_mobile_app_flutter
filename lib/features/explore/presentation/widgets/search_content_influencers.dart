import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/recent_searches_service.dart';

class SearchContentInfluencers extends StatefulWidget {
  final String searchQuery;

  const SearchContentInfluencers({
    super.key,
    required this.searchQuery,
  });

  @override
  _SearchContentInfluencersState createState() =>
      _SearchContentInfluencersState();
}

class _SearchContentInfluencersState extends State<SearchContentInfluencers> {
  final RecentSearchesService _recentSearchesService = RecentSearchesService();
  List<RecentSearch> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void didUpdateWidget(SearchContentInfluencers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery.isEmpty) {
      _loadRecentSearches();
    }
  }

  Future<void> _loadRecentSearches() async {
    final recentSearches = await _recentSearchesService.getRecentSearches();
    setState(() {
      _recentSearches =
          recentSearches.where((s) => s.type == 'influencer').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar búsquedas recientes o estado vacío cuando no hay query
    if (widget.searchQuery.isEmpty) {
      return _recentSearches.isEmpty
          ? _buildEmptyState()
          : _buildRecentSearchesState();
    }

    // Para búsquedas activas, mostrar mensaje de desarrollo
    return _buildDevelopmentState();
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
          _recentSearchesService.addRecentSearch(recentSearch);
          _loadRecentSearches();
          print('Tap en búsqueda reciente de influencer: ${recentSearch.name}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 12),
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
              GestureDetector(
                onTap: () async {
                  await _recentSearchesService.removeRecentSearch(
                    recentSearch.id,
                    recentSearch.type,
                  );
                  _loadRecentSearches();
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

  Widget _buildDevelopmentState() {
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
              'Búsqueda de influencers en desarrollo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta funcionalidad estará disponible pronto',
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
}
