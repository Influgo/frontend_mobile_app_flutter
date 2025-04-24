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
      final response = await _service.getEntrepreneurships();

      // Extract unique categories from entrepreneurships
      final uniqueCategories = response.content
          .map((e) => e.category)
          .where((category) => category != 'N/A')
          .toSet()
          .toList();

      // Sort categories alphabetically and add "Todos" at the beginning
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
    if (_selectedCategory == "Todos") {
      return _entrepreneurships;
    }
    return _entrepreneurships
        .where((e) => e.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_entrepreneurships.isEmpty) {
      /*return const NoResultsContent(
        message: "No se encontraron emprendimientos",
        suggestion: "Intenta recargar la pantalla o verifica tu conexión",
      );*/
    }

    final filteredEntrepreneurships = _getFilteredEntrepreneurships();

    // Para sección "Más recientes", simplemente tomar los últimos emprendimientos
    final recentEntrepreneurships =
        List<Entrepreneurship>.from(filteredEntrepreneurships)
          ..sort((a, b) => b.id.compareTo(a.id));

    final mostRecent = recentEntrepreneurships.take(5).toList();

    // Para "Más colaboraciones", podríamos ordenarlos por cantidad de archivos compartidos
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
            });
          },
          categories: _categories,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchEntrepreneurships,
            child: ListView(
              padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (mostRecent.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: HorizontalCardsSection(
                      title: "Más recientes",
                      cards: mostRecent
                          .map((e) => BusinessCardWidget(entrepreneurship: e))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 16),
                if (mostCollaborations.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: HorizontalCardsSection(
                      title: "Más colaboraciones",
                      cards: mostCollaborations
                          .map((e) => BusinessCardWidget(entrepreneurship: e))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 16),
                if (mostCollaborations.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: HorizontalCardsSection(
                      title: "Mejor valoración",
                      cards: mostCollaborations
                          .map((e) => BusinessCardWidget(entrepreneurship: e))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
