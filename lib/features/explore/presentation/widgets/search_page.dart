import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_tab_item.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/search_content_influencers.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/search_content_entrepreneurships.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/search_suggestions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _submittedQuery = '';
  bool _showTabs = false;
  String? _userType;
  bool _isInfluencerFirst = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    // Listener para cambios en el texto de búsqueda
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        // Ocultar tabs cuando se está escribiendo
        if (_searchQuery.isEmpty) {
          _showTabs = false;
          _submittedQuery = '';
        }
      });
    });

    _getUserType();
  }

  Future<void> _getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Primero intentar obtener el rol de usuario almacenado localmente
      final storedUserRole = prefs.getString('userRole');
      if (storedUserRole != null && storedUserRole.isNotEmpty) {
        setState(() {
          _userType = storedUserRole;
          // Si el usuario es ENTREPRENEUR, mostrar influencers primero
          // Si el usuario es INFLUENCER, mostrar emprendimientos primero
          _isInfluencerFirst = (_userType?.toUpperCase() == 'ENTREPRENEUR');
        });
        // Reset TabController to index 0 when user type is determined
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_tabController.index != 0) {
            _tabController.animateTo(0);
          }
        });
        return;
      }

      // Si no está almacenado localmente, intentar obtenerlo de la API
      final userIdentifier = prefs.getString('userIdentifier');
      final userId = prefs.getString('userId');
      final token = prefs.getString('token');

      if (token != null && (userIdentifier != null || userId != null)) {
        final identifier = userIdentifier?.isNotEmpty == true ? userIdentifier! : userId!;
        
        final response = await http.get(
          Uri.parse('https://influyo-testing.ryzeon.me/api/v1/account/$identifier'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          
          // Extraer el rol del usuario de userDto.roles[0].role.name
          String userRole = '';
          if (data['userDto'] != null && data['userDto']['roles'] != null && data['userDto']['roles'].isNotEmpty) {
            final roles = data['userDto']['roles'] as List;
            if (roles.isNotEmpty && roles[0]['role'] != null) {
              userRole = roles[0]['role']['name'] ?? '';
            }
          }
          
          setState(() {
            _userType = userRole;
            
            // Si se obtiene el rol de usuario de la API, almacenarlo localmente
            if (_userType != null && _userType!.isNotEmpty) {
              prefs.setString('userRole', _userType!);
              _isInfluencerFirst = (_userType?.toUpperCase() == 'ENTREPRENEUR');
            } else {
              // Por defecto, mostrar influencers primero (asumiendo usuario emprendedor)
              _isInfluencerFirst = true;
            }
          });
          
          // Reset TabController to index 0 when user type is determined from API
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_tabController.index != 0) {
              _tabController.animateTo(0);
            }
          });
        }
      }
    } catch (e) {
      // En caso de error, mantener el orden por defecto
      print('Error getting user type: $e');
      setState(() {
        _isInfluencerFirst = true; // Por defecto
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getCurrentSearchType() {
    // Para búsquedas unificadas, siempre retornar 'unified'
    // El SearchSuggestions ahora busca en ambos tipos automáticamente
    return 'entrepreneur'; // Mantenemos por compatibilidad, pero ahora busca en ambos
  }

  void _onSearchSubmitted() {
    if (_searchQuery.trim().isNotEmpty) {
      setState(() {
        _submittedQuery = _searchQuery.trim();
        _showTabs = true;
      });
      // Ocultar el teclado
      FocusScope.of(context).unfocus();
      
      // Forzar que el TabController se reinicie en el tab 0
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
        }
      });
    }
  }

  List<Widget> _getTabsInOrder() {
    if (_isInfluencerFirst) {
      return [
        CustomTabItem(
          title: 'Influencers',
          index: 0,
          tabController: _tabController,
        ),
        CustomTabItem(
          title: 'Emprendimientos',
          index: 1,
          tabController: _tabController,
        ),
      ];
    } else {
      return [
        CustomTabItem(
          title: 'Emprendimientos',
          index: 0,
          tabController: _tabController,
        ),
        CustomTabItem(
          title: 'Influencers',
          index: 1,
          tabController: _tabController,
        ),
      ];
    }
  }

  List<Widget> _getTabContentInOrder() {
    if (_isInfluencerFirst) {
      return [
        SearchContentInfluencers(
          key: ValueKey('influencers_${_submittedQuery}'),
          searchQuery: _submittedQuery,
        ),
        SearchContentEntrepreneurships(
          key: ValueKey('entrepreneurships_${_submittedQuery}'),
          searchQuery: _submittedQuery,
        ),
      ];
    } else {
      return [
        SearchContentEntrepreneurships(
          key: ValueKey('entrepreneurships_${_submittedQuery}'),
          searchQuery: _submittedQuery,
        ),
        SearchContentInfluencers(
          key: ValueKey('influencers_${_submittedQuery}'),
          searchQuery: _submittedQuery,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                // Botón de retroceso
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                // Caja de búsqueda expandida
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearchSubmitted(),
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(Icons.search, size: 20),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFEDEFF1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs Section - Solo mostrar cuando _showTabs es true
          if (_showTabs) ...[
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.transparent,
                  tabs: _getTabsInOrder(),
                ),
                // Animated indicator
                Stack(
                  children: [
                    Container(
                      height: 2,
                      color: Colors.grey[300],
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double tabWidth = constraints.maxWidth / 2;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(
                            left: _tabController.index * tabWidth,
                          ),
                          width: tabWidth,
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFC20B0C),
                                Color(0xFF7E0F9D),
                                Color(0xFF2616C7),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
          // Content Section
          Expanded(
            child: _showTabs
                ? TabBarView(
                    key: ValueKey('${_isInfluencerFirst}_${_submittedQuery}'),
                    controller: _tabController,
                    children: _getTabContentInOrder(),
                  )
                : SearchSuggestions(
                    searchQuery: _searchQuery,
                    searchType: _getCurrentSearchType(),
                    onSuggestionTap: (suggestion) {
                      _searchController.text = suggestion;
                      _onSearchSubmitted();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
