import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExploraPage extends StatefulWidget {
  @override
  _ExploraPageState createState() => _ExploraPageState();
}

class _ExploraPageState extends State<ExploraPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = "Todos"; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0, bottom: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: ' Buscar',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Icon(Icons.search),
                        ),
                        filled: true,
                        fillColor: Color(0xFFEDEFF1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: SvgPicture.asset(
                        'assets/icons/notificationsicon.svg',
                        width: 22,
                        height: 22,
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
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.transparent,
                  tabs: [
                    _buildTabItem('Influencers', 0),
                    _buildTabItem('Emprendimientos', 1),
                  ],
                ),
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
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(left: _tabController.index * tabWidth),
                          width: tabWidth,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFC20B0C), Color(0xFF7E0F9D), Color(0xFF2616C7)],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent(),
                  _buildTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        _buildScrollableFilters(),
        Expanded(child: _buildNoResultsContent()),
      ],
    );
  }

  Widget _buildScrollableFilters() {
    List<String> categorias = [
      "Todos", "Moda y Belleza", "Viajes", "Arte", "Fitness", "Cultura", "Tecnología", 
      "Gastronomía", "Deportes", "Negocios", "Cine", "Música"
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterButton(),
            ...List.generate(categorias.length, (index) {
              return _buildCategoryButton(
                categorias[index], 
                isActive: categorias[index] == _selectedCategory,
                isLast: index == categorias.length - 1
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/noSearchResults.png',
            width: 160,
            height: 160,
          ),
          SizedBox(height: 16),
          Text(
            'Ups...',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No encontramos resultados que coincidan con tus criterios de búsqueda. Prueba con otros.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.black),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: SvgPicture.asset(
          'assets/icons/filtericon.svg',
          width: 14, 
          height: 14, 
          colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text, {bool isActive = false, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(left: 4.0, right: isLast ? 16.0 : 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = text; 
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.black : Colors.white,
          foregroundColor: isActive ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.black),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    return Tab(
      child: _tabController.index == index
          ? ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [Color(0xFFC20B0C), Color(0xFF7E0F9D), Color(0xFF2616C7)],
                ).createShader(bounds);
              },
              child: Text(
                title,
                style: TextStyle(color: Colors.white),
              ),
            )
          : Text(
              title,
              style: TextStyle(color: Colors.grey),
            ),
    );
  }
}
