import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final List<String> categories;
  final List<String> selectedCategories;
  final String selectedModality;
  final String selectedLocation;
  final Function(List<String>, String, String) onApplyFilter;

  const FilterModal({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.selectedModality,
    required this.selectedLocation,
    required this.onApplyFilter,
  });

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late List<String> _selectedCategories;
  late String _selectedModality;
  late String _selectedLocation;

  // Modalidades disponibles (aunque no se usen en el filtrado real)
  final List<String> _modalities = ["Todos", "Presencial", "Virtual"];

  final List<String> _peruCities = [
    "Lima",
    "Arequipa",
    "Trujillo",
    "Chiclayo",
    "Piura",
    "Iquitos",
    "Cusco",
    "Chimbote",
    "Huancayo",
    "Tacna",
    "Ica",
    "Juliaca",
    "Sullana",
    "Ayacucho",
    "Cajamarca",
    "Pucallpa",
    "Huánuco",
    "Tarapoto",
    "Chincha",
    "Paita",
    "Tumbes",
    "Talara",
    "Huaraz",
    "Jaén",
    "Nazca",
    "Moyobamba",
    "Sechura",
    "Catacaos",
    "Lampa",
    "Juanjuí",
    "Casma",
    "Tingo María"
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedModality = widget.selectedModality;
    _selectedLocation = widget.selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ← CAMBIO: Usar Scaffold en lugar de Container
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ← CAMBIO: Usar AppBar estándar
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
            fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section
                  const Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoriesSection(),

                  const SizedBox(height: 24),

                  // Location Section
                  const Text(
                    'Ubicación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Busca emprendimientos en la ciudad seleccionada',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLocationSection(),

                  const SizedBox(height: 32),
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
                      fontWeight: FontWeight.w600,
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
      spacing: 8,
      runSpacing: 8,
      children: widget.categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return GestureDetector(
          onTap: () => _toggleCategory(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
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

  void _toggleCategory(String category) {
    setState(() {
      if (category == "Todos") {
        if (_selectedCategories.contains("Todos")) {
          _selectedCategories.clear();
        } else {
          _selectedCategories.clear();
          _selectedCategories.add("Todos");
        }
      } else {
        if (_selectedCategories.contains(category)) {
          _selectedCategories.remove(category);
        } else {
          _selectedCategories.remove("Todos");
          _selectedCategories.add(category);
        }
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories = ["Todos"];
      _selectedModality = "Todos";
      _selectedLocation = "Lima";
    });
  }

  void _applyFilters() {
    widget.onApplyFilter(
        _selectedCategories, _selectedModality, _selectedLocation);
    Navigator.pop(context);
  }

  // Helper para mostrar cuántos filtros están activos
  int _getFilterCount() {
    int count = 0;
    if (!_selectedCategories.contains("Todos"))
      count += _selectedCategories.length;
    if (_selectedLocation != "Lima") count += 1;
    return count;
  }
}
