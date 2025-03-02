import 'package:flutter/material.dart';

class ExploraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
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
                      child: Icon(Icons.filter_list),
                    ),
                  ),
                  _buildCategoryButton('Todos'),
                  _buildCategoryButton('Moda y Belleza'),
                  _buildCategoryButton('Viajes'),
                  _buildCategoryButton('Arte'),
                  _buildCategoryButton('Fitness'),
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: 'Influencers'),
                Tab(text: 'Emprendimientos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Contenido de la pestaña Influencers
                  Center(child: Text('Contenido de Influencers')),
                  // Contenido de la pestaña Emprendimientos
                  Center(child: Text('Contenido de Emprendimientos')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Añadido padding vertical
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
        child: Text(text),
      ),
    );
  }
}