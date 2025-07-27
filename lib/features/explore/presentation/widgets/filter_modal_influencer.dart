import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/core/constants/filter_constants.dart';

class FilterModalInfluencer extends StatefulWidget {
  final List<String>? categories; // Opcional, se usa lista interna por defecto
  final List<String> selectedCategories;
  final String selectedLocation;
  final Function(List<String>, String) onApplyFilter;

  const FilterModalInfluencer({
    super.key,
    this.categories, // Opcional
    required this.selectedCategories,
    required this.selectedLocation,
    required this.onApplyFilter,
  });

  @override
  _FilterModalInfluencerState createState() => _FilterModalInfluencerState();
}

class _FilterModalInfluencerState extends State<FilterModalInfluencer> {
  late List<String> _selectedCategories;
  late String _selectedLocation;

  // Categorías disponibles (usa las del widget o las por defecto)
  late final List<String> _categories;

  final List<String> _peruCities = [
    "Todos",
    "Amazonas",
    "Ancash",
    "Apurimac",
    "Arequipa",
    "Ayacucho",
    "Cajamarca",
    "Callao",
    "Cusco",
    "Huancavelica",
    "Huánuco",
    "Ica",
    "Junín",
    "La Libertad",
    "Lambayeque",
    "Lima",
    "Loreto",
    "Madre de Dios",
    "Moquegua",
    "Pasco",
    "Piura",
    "Puno",
    "San Martín",
    "Tacna",
    "Tumbes",
    "Ucayali"
  ];

  @override
  void initState() {
    super.initState();
    _categories = widget.categories ?? FilterConstants.categories;
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedLocation = "Todos";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
        ),
        title: const Text(
          'Filtro',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Limpiar',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  const Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCategoriesSection(),

                  const SizedBox(height: 16),

                  // Location Section
                  const Text(
                    'Ubicación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Busca influencers en la ciudad seleccionada',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLocationSection(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Apply Button - Fixed at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Aplicar filtro (${_getFilterCount()} seleccionados)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: () => _selectCategory(category),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? Colors.black : Colors.white,
              foregroundColor: isSelected ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(category),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLocation,
          hint: const Text('Selecciona el departamento'),
          isExpanded: true,
          items: _peruCities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLocation = value);
            }
          },
        ),
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      // Solo permitir una categoría seleccionada
      _selectedCategories.clear();
      _selectedCategories.add(category);
    });
  }


  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedLocation = "Todos";
    });
  }

  void _applyFilters() {
    widget.onApplyFilter(
        _selectedCategories, _selectedLocation);
    Navigator.pop(context);
  }

  // Helper para mostrar cuántos filtros están activos
  int _getFilterCount() {
    int count = 0;
    if (_selectedCategories.isNotEmpty) count += 1;
    if (_selectedLocation != "Todos") count += 1;
    return count;
  }
}
