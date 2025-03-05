import 'package:flutter/material.dart';

class ExploraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar',
                            prefixIcon: Icon(Icons.search),
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
                      IconButton(
                        icon: Icon(Icons.notifications),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Reducimos el espacio entre la barra y los filtros
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(Icons.filter_list),
                  _buildCategoryButton('Todos', isActive: true),
                  _buildCategoryButton('Moda y Belleza'),
                  _buildCategoryButton('Viajes'),
                  _buildCategoryButton('Arte'),
                  _buildCategoryButton('Fitness'),
                ],
              ),
            ),
            TabBar(
              labelPadding: EdgeInsets.symmetric(horizontal: 16.0),
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFC20B0C),
                    Color(0xFF7E0F9D),
                    Color(0xFF2616C7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              tabs: [
                _buildGradientTab('Influencers'),
                _buildGradientTab('Emprendimientos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('Contenido de Influencers')),
                  Center(child: Text('Contenido de Emprendimientos')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientTab(String text) {
    return Tab(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              Color(0xFFC20B0C),
              Color(0xFF7E0F9D),
              Color(0xFF2616C7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterButton(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
        child: Icon(icon),
      ),
    );
  }

  Widget _buildCategoryButton(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {},
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
}
