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

// class _TabContentEntrepreneurshipsState
//     extends State<TabContentEntrepreneurships>
//     with AutomaticKeepAliveClientMixin<TabContentEntrepreneurships> {
//   String _selectedCategory = "Todos";
//   final EntrepreneurshipService _service = EntrepreneurshipService();
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   // Almacena todos los emprendimientos originales
//   List<Entrepreneurship> _allEntrepreneurships = [];
//   List<String> _categories = ["Todos"];
//
//   // Listas pre-procesadas para la UI
//   List<Entrepreneurship> _mostRecentDisplay = [];
//   List<Entrepreneurship> _mostCollaborationsDisplay = [];
//   List<Entrepreneurship> _bestRatedDisplay =
//       []; // Para "Mejor valoración" (corregido)
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//     // _fetchEntrepreneurships();
//     if (_allEntrepreneurships.isEmpty && !_isLoading) {
//       // Solo carga si no hay datos y no está cargando
//       _fetchEntrepreneurships();
//     }
//   }
//
//   Future<void> _fetchEntrepreneurships() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       // Limpiar listas de display mientras se carga
//       _mostRecentDisplay = [];
//       _mostCollaborationsDisplay = [];
//       _bestRatedDisplay = [];
//     });
//
//     try {
//       final response = await _service.getEntrepreneurships();
//       _allEntrepreneurships = response.content; // Guardamos la lista original
//
//       // Extract unique categories from entrepreneurships
//       final uniqueCategories =
//           _allEntrepreneurships // Usar la lista original para categorías
//               .map((e) => e.category)
//               .where((category) =>
//                   category != 'N/A' &&
//                   category.isNotEmpty) // Asegurar que no sea vacío también
//               .toSet()
//               .toList();
//
//       // Sort categories alphabetically and add "Todos" at the beginning
//       uniqueCategories.sort();
//       _categories = ["Todos", ...uniqueCategories]; // Más eficiente
//
//       _processAndPrepareDisplayData(); // Procesar datos para la UI
//
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error al cargar los emprendimientos: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }
//
//   // Método para procesar y preparar las listas para mostrar
//   void _processAndPrepareDisplayData() {
//     // 1. Filtrar según la categoría seleccionada
//     List<Entrepreneurship> filteredEntrepreneurships;
//     if (_selectedCategory == "Todos") {
//       // Crear una copia para las operaciones de sort si _allEntrepreneurships no debe modificarse
//       filteredEntrepreneurships =
//           List<Entrepreneurship>.from(_allEntrepreneurships);
//     } else {
//       filteredEntrepreneurships = _allEntrepreneurships
//           .where((e) => e.category == _selectedCategory)
//           .toList();
//     }
//
//     // Si después de filtrar no hay nada, limpiar las listas de display
//     if (filteredEntrepreneurships.isEmpty) {
//       _mostRecentDisplay = [];
//       _mostCollaborationsDisplay = [];
//       _bestRatedDisplay = [];
//       // No es necesario setState aquí si _processAndPrepareDisplayData
//       // siempre se llama dentro de un contexto de setState (initState, onRefresh, onCategorySelected)
//       return;
//     }
//
//     // 2. Preparar "Más recientes"
//     final recentTemp = List<Entrepreneurship>.from(filteredEntrepreneurships)
//       ..sort((a, b) => b.id.compareTo(a.id));
//     _mostRecentDisplay = recentTemp.take(5).toList();
//
//     // 3. Preparar "Más colaboraciones"
//     final collaborationsTemp =
//         List<Entrepreneurship>.from(filteredEntrepreneurships)
//           ..sort((a, b) => b.s3Files.length.compareTo(a.s3Files.length));
//     _mostCollaborationsDisplay = collaborationsTemp.take(5).toList();
//
//     // 4. Preparar "Mejor valoración"
//     // ¡¡¡IMPORTANTE!!!: Esta sección necesita un campo de datos real para valoración.
//     // Como placeholder, para que no sea igual a "Más colaboraciones" ni a "Más recientes",
//     // la ordenaremos por ID ascendente (los más antiguos).
//     // Reemplaza esta lógica cuando tengas el campo de valoración en tu modelo Entrepreneurship.
//     // Ejemplo: ..sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
//     final ratedTemp = List<Entrepreneurship>.from(filteredEntrepreneurships)
//       ..sort((a, b) => a.id.compareTo(b.id)); // Placeholder: ID ascendente
//     _bestRatedDisplay = ratedTemp.take(5).toList();
//   }
//
//   void _onCategorySelected(String newCategory) {
//     setState(() {
//       _selectedCategory = newCategory;
//       _processAndPrepareDisplayData(); // Reprocesar datos cuando cambia el filtro
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (_errorMessage != null) {
//       return Center(child: Text(_errorMessage!));
//     }
//
//     // Se usará _allEntrepreneurships para la comprobación general de si hay datos.
//     // Las listas de display (_mostRecentDisplay, etc.) se usarán para las secciones.
//     if (_allEntrepreneurships.isEmpty) {
//       // Cambio aquí: usar _allEntrepreneurships
//       // Si tienes un widget NoResultsContent, úsalo. Sino, un Text simple.
//       // return const NoResultsContent(
//       //   message: "No se encontraron emprendimientos",
//       //   suggestion: "Intenta recargar la pantalla o verifica tu conexión",
//       // );
//       return const Center(
//         child: Text("No se encontraron emprendimientos. Intenta recargar."),
//       );
//     }
//
//     // La UI se construye ahora con las listas pre-procesadas.
//     // Ya no se llama a _getFilteredEntrepreneurships() ni se procesan listas aquí.
//
//     return Column(
//       children: [
//         ScrollableFilters(
//           selectedCategory: _selectedCategory,
//           onCategorySelected: _onCategorySelected, // Usar el método wrapper
//           categories: _categories,
//         ),
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: _fetchEntrepreneurships,
//             child: ListView(
//               padding: const EdgeInsets.only(
//                   top: 2,
//                   left: 2,
//                   right: 2,
//                   bottom: 70), // Añadido padding inferior para FAB o similares
//               physics: const AlwaysScrollableScrollPhysics(),
//               children: [
//                 if (_mostRecentDisplay.isNotEmpty)
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: HorizontalCardsSection(
//                       title: "Más recientes",
//                       cards: _mostRecentDisplay // Usar lista pre-procesada
//                           .map((e) => BusinessCardWidget(entrepreneurship: e))
//                           .toList(),
//                     ),
//                   ),
//                 if (_mostRecentDisplay.isNotEmpty)
//                   const SizedBox(
//                       height:
//                           16), // Mostrar SizedBox solo si la sección anterior existe
//
//                 if (_mostCollaborationsDisplay.isNotEmpty)
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: HorizontalCardsSection(
//                       title: "Más colaboraciones",
//                       cards:
//                           _mostCollaborationsDisplay // Usar lista pre-procesada
//                               .map((e) =>
//                                   BusinessCardWidget(entrepreneurship: e))
//                               .toList(),
//                     ),
//                   ),
//                 if (_mostCollaborationsDisplay.isNotEmpty)
//                   const SizedBox(
//                       height:
//                           16), // Mostrar SizedBox solo si la sección anterior existe
//
//                 // Sección "Mejor valoración" corregida
//                 if (_bestRatedDisplay.isNotEmpty)
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: HorizontalCardsSection(
//                       title:
//                           "Mejor valoración", // O "Mejor valoración (Placeholder)" si prefieres
//                       cards:
//                           _bestRatedDisplay // Usar la lista corregida y pre-procesada
//                               .map((e) =>
//                                   BusinessCardWidget(entrepreneurship: e))
//                               .toList(),
//                     ),
//                   ),
//                 // Si hay una tercera sección, también considerar un SizedBox después
//                 if (_bestRatedDisplay.isNotEmpty) const SizedBox(height: 16),
//
//                 // Lógica opcional para mostrar un mensaje si un filtro no devuelve resultados
//                 // para ninguna de las secciones, pero SÍ hay emprendimientos en general.
//                 if (_selectedCategory != "Todos" &&
//                     _allEntrepreneurships
//                         .isNotEmpty && // Hay emprendimientos en total
//                     _mostRecentDisplay.isEmpty &&
//                     _mostCollaborationsDisplay.isEmpty &&
//                     _bestRatedDisplay.isEmpty)
//                   const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(
//                       child: Text(
//                           "No hay emprendimientos en esta categoría para mostrar en las secciones destacadas."),
//                     ),
//                   ),
//
//                 // Lógica opcional para mostrar un mensaje si "Todos" está seleccionado,
//                 // hay emprendimientos en total, pero no suficientes para llenar las secciones.
//                 if (_selectedCategory == "Todos" &&
//                     _allEntrepreneurships.isNotEmpty &&
//                     _mostRecentDisplay.isEmpty &&
//                     _mostCollaborationsDisplay.isEmpty &&
//                     _bestRatedDisplay.isEmpty)
//                   const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(
//                       child: Text(
//                           "No hay suficientes datos para mostrar secciones destacadas."),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }



class _TabContentEntrepreneurshipsState
    extends State<TabContentEntrepreneurships>
    with AutomaticKeepAliveClientMixin<TabContentEntrepreneurships> {
  String _selectedCategory = "Todos";
  final EntrepreneurshipService _service = EntrepreneurshipService();
  
  // Estados de carga
  bool _isInitialLoading = true; // Para la carga inicial
  bool _isLoadingMoreAll = false; // Para cargar más emprendimientos a _allEntrepreneurships
  String? _errorMessage;

  // Almacena todos los emprendimientos originales y paginación
  List<Entrepreneurship> _allEntrepreneurships = [];
  int _currentPageAll = 0;
  final int _pageSizeAll = 20; // Tamaño de página para la carga general
  bool _hasMoreAll = true; // Si hay más emprendimientos generales por cargar

  List<String> _categories = ["Todos"];

  // Listas pre-procesadas para la UI y contadores de ítems visibles
  List<Entrepreneurship> _mostRecentDisplay = [];
  int _visibleRecentCount = 5; // Cuántos mostrar inicialmente y al cargar más

  List<Entrepreneurship> _mostCollaborationsDisplay = [];
  int _visibleCollaborationsCount = 5;

  List<Entrepreneurship> _bestRatedDisplay = [];
  int _visibleBestRatedCount = 5;
  
  final int _itemsToLoadMore = 5; // Cuántos ítems añadir al presionar "cargar más" en una sección

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (_allEntrepreneurships.isEmpty && !_isInitialLoading) {
      _fetchEntrepreneurships(isInitialLoad: true);
    } else if (_allEntrepreneurships.isEmpty) { // Caso inicial absoluto
       _fetchEntrepreneurships(isInitialLoad: true);
    }
  }

  Future<void> _fetchEntrepreneurships({bool isInitialLoad = false, bool loadMore = false}) async {
    if (loadMore && !_hasMoreAll) {
      // No hay más datos generales que cargar
      if (mounted) setState(() => _isLoadingMoreAll = false);
      return;
    }
    if (loadMore && _isLoadingMoreAll) return; // Ya está cargando más
    if (isInitialLoad && _isInitialLoading && _allEntrepreneurships.isNotEmpty) return; // Ya cargó inicialmente


    setState(() {
      if (isInitialLoad) {
        _isInitialLoading = true;
        // Limpiar todo para una carga/re-carga inicial
        _allEntrepreneurships = [];
        _currentPageAll = 0;
        _hasMoreAll = true;
        _resetVisibleCounts(); // Resetea contadores de visualización
      }
      if (loadMore) {
        _isLoadingMoreAll = true;
        _currentPageAll++; // Incrementar la página para la API
      }
      _errorMessage = null;
    });

    try {
      final response = await _service.getEntrepreneurships(
        page: _currentPageAll,
        size: _pageSizeAll,
        sortField: "updatedAt", // O el sortField por defecto que prefieras
      );

      if (mounted) {
        setState(() {
          _allEntrepreneurships.addAll(response.content);
          _hasMoreAll = response.content.length == _pageSizeAll;

          if (isInitialLoad) {
            final uniqueCategories = _allEntrepreneurships
                .map((e) => e.category)
                .where((category) => category != 'N/A' && category.isNotEmpty)
                .toSet()
                .toList();
            uniqueCategories.sort();
            _categories = ["Todos", ...uniqueCategories];
          }
          
          _processAndPrepareDisplayData(); 

          if (isInitialLoad) _isInitialLoading = false;
          if (loadMore) _isLoadingMoreAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar emprendimientos: ${e.toString()}';
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

  void _processAndPrepareDisplayData() {
    List<Entrepreneurship> filteredEntrepreneurships;
    if (_selectedCategory == "Todos") {
      filteredEntrepreneurships = List<Entrepreneurship>.from(_allEntrepreneurships);
    } else {
      filteredEntrepreneurships = _allEntrepreneurships
          .where((e) => e.category == _selectedCategory)
          .toList();
    }

    if (filteredEntrepreneurships.isEmpty && _allEntrepreneurships.isNotEmpty) {
      // Hay emprendimientos en general, pero no para esta categoría
      _mostRecentDisplay = [];
      _mostCollaborationsDisplay = [];
      _bestRatedDisplay = [];
      // setState no es necesario aquí si siempre se llama desde un contexto de setState
      return;
    }
    
    // Preparar "Más recientes"
    final recentTemp = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => b.id.compareTo(a.id)); // Asumiendo ID más alto es más reciente
    _mostRecentDisplay = recentTemp.take(_visibleRecentCount).toList();

    // Preparar "Más colaboraciones"
    final collaborationsTemp = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => b.s3Files.length.compareTo(a.s3Files.length));
    _mostCollaborationsDisplay = collaborationsTemp.take(_visibleCollaborationsCount).toList();

    // Preparar "Mejor valoración" (Placeholder)
    final ratedTemp = List<Entrepreneurship>.from(filteredEntrepreneurships)
      ..sort((a, b) => a.id.compareTo(b.id)); // Placeholder: ID ascendente
    _bestRatedDisplay = ratedTemp.take(_visibleBestRatedCount).toList();
  }

  void _onCategorySelected(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
      _resetVisibleCounts(); // Resetea contadores para la nueva categoría
      _processAndPrepareDisplayData(); // Reprocesar con los datos actuales
      // No es necesario recargar _allEntrepreneurships a menos que se quiera explícitamente
    });
  }

  // Funciones para cargar más en cada sección
  void _loadMoreForRecent() {
    setState(() {
      _visibleRecentCount += _itemsToLoadMore;
    });
    // Si necesitamos más datos de los que _allEntrepreneurships puede proveer
    // para la cantidad visible actual con el filtro actual, cargamos más.
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

  // Verifica si se necesitan más datos generales y los carga
  void _checkAndFetchMoreAllDataIfNeeded() {
    // Heurística simple: si el número de elementos visibles es cercano al total
    // de _allEntrepreneurships filtrados, podríamos necesitar más.
    // Una heurística más precisa sería contar cuántos elementos CUMPLEN el criterio de cada sección
    // dentro de _allEntrepreneurships filtrados y comparar con _visibleXXXCount.
    
    // Por ahora, una llamada más general: si alguna lista de display no pudo llenarse
    // hasta su _visibleXXXCount deseado Y hay más datos en el backend, cargar más.
    
    bool needsMoreData = false;
    List<Entrepreneurship> filtered = _selectedCategory == "Todos"
        ? _allEntrepreneurships
        : _allEntrepreneurships.where((e) => e.category == _selectedCategory).toList();

    // Re-ordenamos y verificamos si hay suficientes para los contadores actuales
    final recentTempCheck = List<Entrepreneurship>.from(filtered)..sort((a,b) => b.id.compareTo(a.id));
    if (recentTempCheck.length < _visibleRecentCount) needsMoreData = true;
    
    final collabTempCheck = List<Entrepreneurship>.from(filtered)..sort((a, b) => b.s3Files.length.compareTo(a.s3Files.length));
    if (collabTempCheck.length < _visibleCollaborationsCount) needsMoreData = true;

    final ratedTempCheck = List<Entrepreneurship>.from(filtered)..sort((a,b) => a.id.compareTo(b.id));
    if (ratedTempCheck.length < _visibleBestRatedCount) needsMoreData = true;


    if (needsMoreData && _hasMoreAll && !_isLoadingMoreAll) {
      _fetchEntrepreneurships(loadMore: true);
    } else {
      // Si no se necesita cargar más de la API, solo reprocesar con los nuevos counts
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
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    if (_isInitialLoading && _allEntrepreneurships.isEmpty) { // Solo muestra loading si realmente es la primera carga
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _allEntrepreneurships.isEmpty) { // Mostrar error solo si no hay datos para mostrar
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(onPressed: _handleRefresh, child: const Text("Reintentar"))
          ],
        ),
      );
    }

    if (_allEntrepreneurships.isEmpty && !_isInitialLoading) { // Después de intentar cargar y no hay nada
      return const Center(
        child: Text("No se encontraron emprendimientos. Intenta recargar."),
      );
    }

    // Determinar si hay suficientes emprendimientos filtrados para cada sección
    List<Entrepreneurship> filteredForCounts = _selectedCategory == "Todos"
        ? _allEntrepreneurships
        : _allEntrepreneurships.where((e) => e.category == _selectedCategory).toList();
    
    // Para "Más Recientes"
    final sortedRecent = List<Entrepreneurship>.from(filteredForCounts)..sort((a,b) => b.id.compareTo(a.id));
    bool canLoadMoreRecent = _mostRecentDisplay.length < sortedRecent.length || (_hasMoreAll && _mostRecentDisplay.length == sortedRecent.length);

    // Para "Más Colaboraciones"
    final sortedCollab = List<Entrepreneurship>.from(filteredForCounts)..sort((a,b) => b.s3Files.length.compareTo(a.s3Files.length));
    bool canLoadMoreCollab = _mostCollaborationsDisplay.length < sortedCollab.length || (_hasMoreAll && _mostCollaborationsDisplay.length == sortedCollab.length);

    // Para "Mejor Valoración"
    final sortedRated = List<Entrepreneurship>.from(filteredForCounts)..sort((a,b) => a.id.compareTo(b.id));
    bool canLoadMoreRated = _bestRatedDisplay.length < sortedRated.length || (_hasMoreAll && _bestRatedDisplay.length == sortedRated.length);


    return Column(
      children: [
        ScrollableFilters(
          selectedCategory: _selectedCategory,
          onCategorySelected: _onCategorySelected,
          categories: _categories,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              padding: const EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 70),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (_mostRecentDisplay.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: HorizontalCardsSection(
                      title: "Más recientes",
                      cards: _mostRecentDisplay
                          .map((e) => BusinessCardWidget(entrepreneurship: e))
                          .toList(),
                      onLoadMore: canLoadMoreRecent ? _loadMoreForRecent : null, // Pasa la función
                      isLoadingMore: _isLoadingMoreAll && (_visibleRecentCount > _mostRecentDisplay.length), // Si está cargando general y esta sección espera más
                      hasMore: canLoadMoreRecent,
                    ),
                  ),
                if (_mostRecentDisplay.isNotEmpty) const SizedBox(height: 16),

                if (_mostCollaborationsDisplay.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: HorizontalCardsSection(
                      title: "Más colaboraciones",
                      cards: _mostCollaborationsDisplay
                          .map((e) => BusinessCardWidget(entrepreneurship: e))
                          .toList(),
                      onLoadMore: canLoadMoreCollab ? _loadMoreForCollaborations : null,
                      isLoadingMore: _isLoadingMoreAll && (_visibleCollaborationsCount > _mostCollaborationsDisplay.length),
                      hasMore: canLoadMoreCollab,
                    ),
                  ),
                if (_mostCollaborationsDisplay.isNotEmpty) const SizedBox(height: 16),

                if (_bestRatedDisplay.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: HorizontalCardsSection(
                      title: "Mejor valoración",
                      cards: _bestRatedDisplay
                          .map((e) => BusinessCardWidget(entrepreneurship: e))
                          .toList(),
                      onLoadMore: canLoadMoreRated ? _loadMoreForBestRated : null,
                      isLoadingMore: _isLoadingMoreAll && (_visibleBestRatedCount > _bestRatedDisplay.length),
                      hasMore: canLoadMoreRated,
                    ),
                  ),
                if (_bestRatedDisplay.isNotEmpty) const SizedBox(height: 16),
                
                // Indicador de carga general al final si aplica
                if (_isLoadingMoreAll && _allEntrepreneurships.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // Mensajes de "no hay resultados"
                if (_selectedCategory != "Todos" &&
                    _allEntrepreneurships.isNotEmpty &&
                    _mostRecentDisplay.isEmpty &&
                    _mostCollaborationsDisplay.isEmpty &&
                    _bestRatedDisplay.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                          "No hay emprendimientos en esta categoría para mostrar."),
                    ),
                  ),
                
                // ... (otros mensajes de no resultados si los tenías)
              ],
            ),
          ),
        ),
      ],
    );
  }
}


