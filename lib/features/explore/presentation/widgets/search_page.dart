import 'package:flutter/material.dart';
import 'package:frontend_mobile_app_flutter/features/authentication/presentation/widgets/custom_tab_item.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/search_content_influencers.dart';
import 'package:frontend_mobile_app_flutter/features/explore/presentation/widgets/search_content_entrepreneurships.dart';

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
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
                    autofocus: true, // Auto-focus para que aparezca el teclado
                    textAlignVertical: TextAlignVertical.center,
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
          // Tabs Section
          Column(
            children: [
              TabBar(
                controller: _tabController,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Colors.transparent,
                tabs: [
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
                ],
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
          // Content Section
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SearchContentInfluencers(searchQuery: _searchQuery),
                SearchContentEntrepreneurships(searchQuery: _searchQuery),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
