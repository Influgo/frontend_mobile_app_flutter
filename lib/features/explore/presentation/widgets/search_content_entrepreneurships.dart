import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/entrepreneurship_service.dart';

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
  List<Entrepreneurship> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _lastSearchQuery = '';

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
      // Usar el método de búsqueda (lo crearemos después)
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
    // Mostrar estado vacío cuando no hay query
    if (widget.searchQuery.isEmpty) {
      return _buildEmptyState();
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
            // Ícono de búsqueda
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
      padding: const EdgeInsets.symmetric(
          vertical: 4), // ← Padding reducido solo vertical
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final entrepreneurship = _searchResults[index];
        return _buildSearchResultItem(entrepreneurship);
      },
    );
  }

  Widget _buildSearchResultItem(Entrepreneurship entrepreneurship) {
    return Container(
      height: 38, // ← Altura fija de 31px
      margin:
          const EdgeInsets.only(bottom: 2), // ← Menos margen entre elementos
      child: InkWell(
        onTap: () {
          // Aquí puedes navegar a la página de detalle del emprendimiento
          print('Tap en: ${entrepreneurship.entrepreneurshipName}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 2), // ← Padding mínimo
          child: Row(
            children: [
              // Avatar más pequeño
              CircleAvatar(
                radius: 12, // ← Reducido de 25 a 12
                backgroundColor: Colors.grey[200],
                backgroundImage: entrepreneurship.entrepreneurLogo?.url != null
                    ? NetworkImage(entrepreneurship.entrepreneurLogo!.url)
                    : null,
                child: entrepreneurship.entrepreneurLogo?.url == null
                    ? Icon(Icons.business,
                        color: Colors.grey[500],
                        size: 12) // ← Ícono más pequeño
                    : null,
              ),
              const SizedBox(width: 12), // ← Espaciado reducido
              // Contenido expandido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // ← Centrar verticalmente
                  children: [
                    Text(
                      entrepreneurship.entrepreneurshipName,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal, // ← Quitado el bold
                        fontSize: 14, // ← Tamaño reducido
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${entrepreneurship.entrepreneursNickname}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10, // ← Tamaño reducido
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
